;;; consult-bibtex.el --- Consulting read interface for bibtex-completion  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  mohsin kaleem

;; Author: mohsin kaleem <mohkale@kisara.moe>
;; Maintainer: Mohsin Kaleem
;; Keywords: tools, completion
;; Version: 0.1
;; Package-Requires: ((emacs "27.1") (bibtex-completion "1.0.0") (consult "0.9"))
;; Homepage: https://github.com/mohkale/consult-bibtex

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Provides a front-end for listing and interacting with `bibtex-completion'
;; entries through `consult' with support for narrowing to specific bibtex
;; types or based on specific properties of a bibtex entry (such as having
;; a PDF).

;;; Code:

(require 'consult)
(require 'bibtex-completion)
(require 'consult-bibtex-embark)

(defgroup consult-bibtex nil
  "Consulting-read for `bibtex-completion'."
  :prefix "consult-bibtex"
  :group 'completion
  :group 'consult)

(defvar consult-bibtex-history nil
  "History for `consult-bibtex'.")

(defcustom consult-bibtex-default-action #'consult-bibtex-insert-citation
  "The default action for the `consult-bibtex' command.")

(defcustom consult-bibtex-pdf-narrow-key ?p
  "Narrowing key used to narrow onto documents with PDFs.")

(defcustom consult-bibtex-note-narrow-key ?n
  "Narrowing key used to narrow onto documents with notes.")

(defcustom consult-bibtex-narrow
  '((?b . "Book")
    (?u . "Unpublished")
    (?l . "Booklet")
    (?a . "Article")
    (?m . "Misc")
    (?p . "Proceedings")
    (?P . "Inproceedings")
    (?B . "Inbook"))
  "Narrowing configuration for `consult-bibtex'."
  :type '(alist :key-type character :value-type string))

(defun consult-bibtex--candidates (&optional cands)
  "Convert `bibtex-completion' candidates to `completing-read' candidates.
CANDS is an optional subset of candidates to convert. When omitted CANDS
defaults to all the candidates configured by `bibtex-completion'."
  (or cands
      (setq cands (bibtex-completion-candidates)))
  (cl-loop
   for cand in cands
   with cand-str = nil
   do (setq cand-str
            (concat (bibtex-completion-get-value "=type=" cand) " "
                    (bibtex-completion-format-entry (cdr cand) (1- (frame-width)))))
   ;; Add a `consult--type' property for narrowing support.
   do (add-text-properties 0 1
                           `(consult--type
                             ,(or
                               (when-let ((type (bibtex-completion-get-value "=type=" cand)))
                                 (car (rassoc (capitalize type) consult-bibtex-narrow)))
                               (car (rassoc "Other" consult-bibtex-narrow)))
                             ;; Symbols are more performant than strings for most situations.
                             bib-type ,(intern (capitalize (bibtex-completion-get-value "=type=" cand)))
                             consult--candidate ,(bibtex-completion-get-value "=key=" cand)
                             has-pdf ,(not (not (bibtex-completion-get-value "=has-pdf=" cand)))
                             has-note ,(not (not (bibtex-completion-get-value "=has-note=" cand))))
                           ;; The trailing type text is there for matching, it'll be removed by consult.
                           cand-str)
   collect cand-str))

(defun consult-bibtex--read-entry (&optional arg cands)
  "Read a bibtex entry.
Optional argument CANDS is the same as for `consult-bibtex--candidates'. ARG
causes `bibtex-completion' re-read all bibtex entries from your bibtex files."
  (when arg
    (bibtex-completion-clear-cache))
  (bibtex-completion-init)
  (let* ((candidates (or cands
                         (consult-bibtex--candidates)))
         (preselect
          (when-let ((key (bibtex-completion-key-at-point)))
            (cl-find-if (lambda (cand)
                          (string-equal key (get-text-property 0 'consult--candidate cand)))
                        candidates))))
    (consult--read candidates
                   :prompt "BibTeX entries: "
                   :require-match t
                   :category 'bibtex-completion
                   :lookup 'consult--lookup-candidate
                   :default preselect
                   :group
                   ;; (consult--type-title consult-bibtex-narrow)
                   (lambda (cand transform)
                     (if transform
                         (substring cand (1+ (length (symbol-name (get-text-property 0 'bib-type cand)))))
                       (symbol-name (get-text-property 0 'bib-type cand))))
                   :narrow
                   ;; Allow narrowing on PDFs and notes, alongside just `consult--type'.
                   (let ((type-narrow (plist-get (consult--type-narrow consult-bibtex-narrow) :predicate)))
                     (list :predicate
                           (lambda (cand)
                             (when consult--narrow
                               (cond
                                ((eq consult--narrow consult-bibtex-pdf-narrow-key)
                                 (get-text-property 0 'has-pdf cand))
                                ((eq consult--narrow consult-bibtex-note-narrow-key)
                                 (get-text-property 0 'has-note cand))
                                (t (funcall type-narrow cand)))))
                           :keys
                           `(,@(and consult-bibtex-pdf-narrow-key
                                    `((,consult-bibtex-pdf-narrow-key . "With PDFs")))
                             ,@(and consult-bibtex-note-narrow-key
                                    `((,consult-bibtex-note-narrow-key . "With Notes")))
                             ,@consult-bibtex-narrow)))
                   :history consult-bibtex-history)))

;;;###autoload
(defun consult-bibtex (entry)
  "Run `consult-bibtex-default-action' on a `bibtex-completion' ENTRY.
When run interactively the completion entry is read interactively."
  (interactive (list (consult-bibtex--read-entry current-prefix-arg)))
  (if consult-bibtex-default-action
      (funcall-interactively consult-bibtex-default-action entry)
    (warn "`consult-bibtex-default-action' is unassigned.")))

(provide 'consult-bibtex)
;;; consult-bibtex.el ends here
