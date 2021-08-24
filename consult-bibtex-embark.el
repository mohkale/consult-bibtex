;;; consult-bibtex-embark.el --- Embark actions and map for `consult-bibtex'  -*- lexical-binding: t; -*-

;; Copyright (C) 2021  mohsin kaleem

;; Author: mohsin kaleem <mohkale@kisara.moe>
;; Maintainer: Mohsin Kaleem

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

;; Embark commands for `bibtex-completion' and `consult-bibtex'.

;;; Code:

(defmacro consult-bibtex-embark-action (name action)
  `(defun ,name (key)
     ,(format "Consult wrapper for `%s'." name)
     (interactive (list (consult-bibtex--read-entry)))
     (if key
         (,action (list key))
       (warn "Failed to extract bibtex key from candidate: %s" key))))

;;;###autoload (autoload 'consult-bibtex-open-any "consult-bibtex-embark")
(consult-bibtex-embark-action consult-bibtex-open-any bibtex-completion-open-any)

;;;###autoload (autoload 'consult-bibtex-open-pdf "consult-bibtex-embark")
(consult-bibtex-embark-action consult-bibtex-open-pdf bibtex-completion-open-pdf)

;;;###autoload (autoload 'consult-bibtex-open-url-or-doi "consult-bibtex-embark")
(consult-bibtex-embark-action consult-bibtex-open-url-or-doi bibtex-completion-open-url-or-doi)

;;;###autoload (autoload 'consult-bibtex-insert-citation "consult-bibtex-embark")
(consult-bibtex-embark-action consult-bibtex-insert-citation bibtex-completion-insert-citation)

;;;###autoload (autoload 'consult-bibtex-insert-reference "consult-bibtex-embark")
(consult-bibtex-embark-action consult-bibtex-insert-reference bibtex-completion-insert-reference)

;;;###autoload (autoload 'consult-bibtex-insert-key "consult-bibtex-embark")
(consult-bibtex-embark-action consult-bibtex-insert-key bibtex-completion-insert-key)

;;;###autoload (autoload 'consult-bibtex-insert-bibtex "consult-bibtex-embark")
(consult-bibtex-embark-action consult-bibtex-insert-bibtex bibtex-completion-insert-bibtex)

;;;###autoload (autoload 'consult-bibtex-add-PDF-attachment "consult-bibtex-embark")
(consult-bibtex-embark-action consult-bibtex-add-PDF-attachment bibtex-completion-add-PDF-attachment)

;;;###autoload (autoload 'consult-bibtex-edit-notes "consult-bibtex-embark")
(consult-bibtex-embark-action consult-bibtex-edit-notes bibtex-completion-edit-notes)

;;;###autoload (autoload 'consult-bibtex-show-entry "consult-bibtex-embark")
(consult-bibtex-embark-action consult-bibtex-show-entry bibtex-completion-show-entry)

;;;###autoload (autoload 'consult-bibtex-add-pdf-to-library "consult-bibtex-embark")
(consult-bibtex-embark-action consult-bibtex-add-pdf-to-library bibtex-completion-add-pdf-to-library)

;;;###autoload (autoload 'consult-bibtex-embark-map "consult-bibtex-embark" nil 'keymap)
(defvar consult-bibtex-embark-map
  (let ((map (make-sparse-keymap)))
    (define-key map "o" #'consult-bibtex-open-pdf)
    (define-key map "u" #'consult-bibtex-open-url-or-doi)
    (define-key map "c" #'consult-bibtex-insert-citation)
    (define-key map "r" #'consult-bibtex-insert-reference)
    (define-key map "k" #'consult-bibtex-insert-key)
    (define-key map "b" #'consult-bibtex-insert-bibtex)
    (define-key map "a" #'consult-bibtex-add-PDF-attachment)
    (define-key map "e" #'consult-bibtex-edit-notes)
    (define-key map "j" #'consult-bibtex-insert-pdftools-link)
    (define-key map "s" #'consult-bibtex-show-entry)
    (define-key map "l" #'consult-bibtex-add-pdf-to-library)
    map)
  "Embark bindings for `bibtex-completion' candidates.")

(provide 'consult-bibtex-embark)
;;; consult-bibtex-embark.el ends here
