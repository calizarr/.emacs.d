;; -*- lexical-binding: t; -*-

(use-package auto-yasnippet
  :ensure t
  :pin melpa
  )

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :commands yas-minor-mode
  :hook ((go-mode . yas-minor-mode)
         (yaml-mode . yas-minor-mode))
  :config (yas-reload-all))

(require 'yasnippet)

(use-package yasnippet-snippets
  :ensure t
  :pin melpa
  )

;; Functions for snippets etc.
(defun my-query-yes-no (prompt result)
  (if (y-or-n-p prompt)
      (concat result "\n")
      "DELETE\n"))

(defun my-query-yes-no-arg (prompt lhs)
  (if (y-or-n-p prompt)
      (let ((rhs (read-from-minibuffer lhs)))
        (concat lhs rhs "\n")
        )
      "DELETE\n"))

(defun int-name (name)
  "Take a physical interface name like ge-0-0-0 and convert it to Juniper format"
  (let* ((split (split-string name "-"))
         (prefix (car split))
         (post (s-join "/" (cdr split))))
    (string-trim-right (s-join "-" (list prefix post)) "-")))
