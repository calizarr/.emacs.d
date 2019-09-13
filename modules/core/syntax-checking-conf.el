;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; (use-package flycheck
;;   :ensure t
;;   :config
;;   (add-hook 'typescript-mode-hook 'flycheck-mode))
