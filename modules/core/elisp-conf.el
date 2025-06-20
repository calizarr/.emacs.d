;; -*- lexical-binding: t; -*-

;; Ensure Elisp References
(use-package elisp-refs
  :ensure)

;; Ensure Loop
(use-package loop
  :ensure)

(defun my-emacs-lisp-mode-setup ()
  (interactive)
  "My emacs lisp mode setup function."
  ;; "-" is almost always part of a function- or variable-name
  (modify-syntax-entry ?- "w")

  ;; make sure we cannot save syntax errors
  (add-hook 'local-write-file-hooks 'check-parens)

  ;; Modify completions, elisp-completion-at-point wouldn't allow me to
  ;; complete elisp things in comments.
  (defalias 'my-elisp-capf (cape-capf-super #'elisp-completion-at-point
                                            #'cape-dabbrev
                                            #'cape-file
                                            #'cape-dict
                                            #'cape-elisp-symbol))
  (setq-local completion-at-point-functions '(my-elisp-capf t))
  )
(add-hook 'emacs-lisp-mode-hook #'my-emacs-lisp-mode-setup)
