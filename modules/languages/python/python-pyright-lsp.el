(use-package lsp-pyright
  :straight t
  :after lsp-mode)

(defun install-pyright ()
  "Installs the pyright python language server"
  (interactive)
  (compile "npm install -g pyright"))
