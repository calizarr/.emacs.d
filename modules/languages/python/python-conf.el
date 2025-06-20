;; -*- lexical-binding: t; -*-

;; (setq python-shell-completion-native-enable nil)

(use-package sphinx-mode
  :ensure t)

(use-package sphinx-doc
  :ensure t)

(add-hook 'python-mode-hook (lambda ()
                              (require 'sphinx-doc)
                              (sphinx-doc-mode t)))

;; When entering python-mode, consider also the snippets in the
;; snippet table "python-mode"
(add-hook 'python-mode-hook
          #'(lambda ()
              (yas-activate-extra-mode 'python-mode)))

(use-package pyenv-mode
  :ensure t
  :pin melpa)

;;; Ruff is a new 2024 much-faster code linter/formatter
(use-package ruff-format)

;;;; Format Python buffers with ~black~
(use-package python-black)

(use-package pytest)

(use-package python-isort)

;;; Pet is Python Executable Tracker.
;;; Supports all kinds of virtualenvs, especially "uv"
(use-package pet
  :ensure t
  :config
  ;;; Master python hook
  (add-hook 'python-base-mode-hook 'pet-mode -10)
  (add-hook 'python-mode-hook 'pet-flycheck-setup))
  ;; (add-hook 'python-base-mode-hook
  ;;           (lambda ()
  ;;             (setq-local python-shell-interpreter (pet-executable-find "python")
  ;;                         python-shell-virtualenv-root (pet-virtualenv-root))

  ;;             (setq-local dap-python-executable python-shell-interpreter)

  ;;             (setq-local python-pytest-executable (pet-executable-find "pytest"))

  ;;             (when-let ((ruff-executable (pet-executable-find "ruff")))
  ;;               (setq-local ruff-format-command ruff-executable)
  ;;               (ruff-format-on-save-mode))

  ;;             (when-let ((black-executable (pet-executable-find "black")))
  ;;               (setq-local python-black-command black-executable)
  ;;               (python-black-on-save-mode))

  ;;             (when-let ((isort-executable (pet-executable-find "isort")))
  ;;               (setq-local python-isort-command isort-executable)
  ;;               (python-isort-on-save-mode)))))
