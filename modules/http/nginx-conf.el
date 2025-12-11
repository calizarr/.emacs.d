;; -*- lexical-binding: t; -*-

;;; nginx-conf --- Provides configuration for nginx-mode and LSP for nginx
;;; Commentary:

;;; Code:
(use-package nginx-mode
  :commands nginx-mode
  :mode ("/nginx/sites-\\(?:available\\|enabled\\)/" . nginx-mode)
  )

;; (add-to-list 'auto-mode-alist '("/nginx/sites-\\(?:available\\|enabled\\)/" . nginx-mode))

(defun install-nginx-lsp ()
  (interactive)
  (compile "python -m pip install nginx-language-server")
  )
