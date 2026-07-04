;; -*- lexical-binding: t; -*-

(use-package lsp-pyright
  :ensure t
  ;; :init (setq lsp-pyright-python-search-functions ('lsp-pyright--locate-python-python 'lsp-pyright--locate-python-venv 'lsp-pyright--locate-venv))
  :custom
  (lsp-pyright-langserver-command "basedpyright") ;; or basedpyright
  (lsp-pyright-python-search-functions '(lsp-pyright--locate-python-python lsp-pyright--locate-python-venv lsp-pyright--locate-venv))
  ;; :config (setq lsp-pyright-python-search-functions ('lsp-pyright--locate-python-python 'lsp-pyright--locate-python-venv 'lsp-pyright--locate-venv))
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred
