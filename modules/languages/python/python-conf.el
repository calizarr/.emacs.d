;; (setq python-shell-completion-native-enable nil)

(use-package sphinx-mode
  :ensure)

(use-package sphinx-doc
  :ensure)

(add-hook 'python-mode-hook (lambda ()
                              (require 'sphinx-doc)
                              (sphinx-doc-mode t)))

;; When entering python-mode, consider also the snippets in the
;; snippet table "python-mode"
(add-hook 'python-mode-hook
          #'(lambda ()
              (yas-activate-extra-mode 'python-mode)))

(use-package pyenv-mode
  :ensure)

(if (is-windows)
    (use-package conda
      :ensure t
      :init
      (let (conda-root (file-name-directory (directory-file-name (file-name-directory (getenv "CONDA_EXE")))))
        (setq conda-anaconda-home (getenv "_CONDA_ROOT")))
      (defun conda--get-path-prefix (env-dir)
        "Get a platform-specific path string to utilize the conda env in ENV-DIR.
It's platform specific in that it uses the platform's native path separator."
        (string-trim (shell-command-to-string (format "conda activate \"%s\"" env-dir))))
      :config
      (conda-env-initialize-interactive-shells)
      (conda-env-initialize-eshell)))
