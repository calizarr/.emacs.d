;; -*- lexical-binding: t -*-

(defun install-pylsp ()
  (interactive)
  (compile "python -m pip install 'python-lsp-server[all]' pylsp-rope pylsp-mypy pyls-memestra python-lsp-black python-lsp-ruff python-lsp-isort ruff jedi-language-server websockets basedpyright"))

;; (setq lsp-pylsp-configuration-sources nil)
(setq
 lsp-pylsp-configuration-sources [ruff]
 lsp-pylsp-plugins-autopep8-enabled nil
 lsp-pylsp-plugins-black-enabled nil
 lsp-pylsp-plugins-isort-enabled t
 lsp-pylsp-plugins-jedi-completion-enabled t
 lsp-pylsp-plugins-jedi-completion-include-class-objects t
 lsp-pylsp-plugins-jedi-completion-include-params t
 lsp-pylsp-plugins-jedi-definition-enabled t
 lsp-pylsp-plugins-jedi-definition-follow-builtin-imports t
 lsp-pylsp-plugins-jedi-definition-follow-imports t
 lsp-pylsp-plugins-jedi-references-enabled t
 lsp-pylsp-plugins-jedi-signature-help-enabled t
 lsp-pylsp-plugins-jedi-symbols-enabled t
 lsp-pylsp-plugins-jedi-use-pyenv-environment t
 lsp-pylsp-plugins-mccabe-enabled nil
 lsp-pylsp-plugins-mypy-dmypy t
 lsp-pylsp-plugins-mypy-enabled nil
 lsp-pylsp-plugins-mypy-live-mode nil
 lsp-pylsp-plugins-mypy-report-progress nil
 lsp-pylsp-plugins-pycodestyle-enabled nil
 lsp-pylsp-plugins-pyflakes-enabled nil
 lsp-pylsp-plugins-pylint-enabled nil
 lsp-pylsp-plugins-rope-autoimport-code-actions-enabled t
 lsp-pylsp-plugins-rope-autoimport-completions-enabled t
 lsp-pylsp-plugins-rope-autoimport-enabled t
 lsp-pylsp-plugins-rope-autoimport-memory t
 lsp-pylsp-plugins-rope-completion-eager t
 lsp-pylsp-plugins-rope-completion-enabled nil
 lsp-pylsp-plugins-ruff-enabled t
 lsp-pylsp-plugins-yapf-enabled nil
 ;; lsp-pylsp-server-command '("pylsp" "--ws" "--port" "10000")
 ;; lsp-pylsp-rename-backend rope
 )
