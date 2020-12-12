;;; go-init -- Provides settings for Golang IDE behavior
;;; Commentary:

;;; Code:
;; Go setup for Emacs

(defun go-run ()
  "Runs go run with current buffer name"
  (interactive)
  (compile (string-join (list "go run" (buffer-name)) " ")))

(use-package go-mode
  :ensure t
  :defer t
  :mode ("\\.go$" . go-mode)
  :bind (:map go-mode-map
         ("C-c C-c" . go-run)))
    

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t))
  ;; (add-hook 'before-save-hook #'lsp-organize-imports t t))

(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(setq lsp-gopls-staticcheck t
      lsp-gopls-complete-unimported t)

(provide 'go-init)
;;; go -init ends here
