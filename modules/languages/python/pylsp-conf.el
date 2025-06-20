;; -*- lexical-binding: t -*-
(defun install-pylsp ()
  (interactive)
  (compile "pip install 'python-lsp-server[all]' pylsp-rope python-lsp-black pylsp-mypy ruff python-lsp-ruff jedi-language-server"))

;; (setq lsp-pylsp-configuration-sources nil)
(setq lsp-pylsp-plugins-black-enabled t
      lsp-pylsp-plugins-pycodestyle-enabled t
      lsp-pylsp-plugins-pylint-enabled t
      lsp-pylsp-plugins-jedi-completion-enabled t
      lsp-pylsp-plugins-jedi-completion-include-class-objects t
      lsp-pylsp-plugins-jedi-completion-include-params t
      lsp-pylsp-plugins-jedi-definition-enabled t
      lsp-pylsp-plugins-jedi-use-pyenv-environment t
      lsp-pylsp-plugins-rope-autoimport-code-actions-enabled t
      lsp-pylsp-plugins-rope-autoimport-completions-enabled t
      lsp-pylsp-plugins-rope-autoimport-enabled t
      lsp-pylsp-plugins-rope-autoimport-memory t
      lsp-pylsp-plugins-rope-completion-enabled t
      lsp-pylsp-plugins-rope-completion-eager t
      lsp-pylsp-plugins-ruff-enabled t
      lsp-pylsp-plugins-yapf-enabled t
      )
