;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode)
  :config
  ;; Flycheck Customization
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))
  (setq-default flycheck-emacs-lisp-load-path 'inherit))
