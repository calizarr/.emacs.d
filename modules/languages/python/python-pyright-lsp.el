(use-package lsp-pyright
  :ensure t
  :after lsp-mode)

(defun install-pyright ()
  "Installs the pyright python language server"
  (interactive)
  (compile "npm install -g pyright"))
