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

;; (defun conda--get-path-prefix (env-dir)
;;   "Get a platform-specific path string to utilize the conda env in ENV-DIR.
;;          It's platform specific in that it uses the platform's native path separator."
;;   (string-trim (shell-command-to-string (format "conda activate \"%s\"" env-dir))))


(defun get-conda-root ()
  "Return the unstable _CONDA_ROOT env variable using the stable CONDA_EXE ENV variable."
  (file-name-directory (directory-file-name (file-name-directory (getenv "CONDA_EXE")))))

(defun check-conda-envs ()
  "Print out all current CONDA environment variables."
  (let
      ((conda-envs (-filter (lambda (x) (string-match "^_?CONDA.*$" x)) process-environment)))
    (dolist (element conda-envs)
      (print (split-string element "=")))))

(defun conda-add-env-postactivate-func ()
  "Add environment variables postactivation"
  (setenv "CONDA_SHLVL" "1")
  ;; (setenv "CONDA_PYTHON_EXE" (convert-standard-filename (subst-char-in-string ?/ ?\\ (concat (get-conda-root) "python.exe"))))
  (setenv "CONDA_PROMPT_MODIFIER" (format "%s%s%s" "(" conda-env-current-name ")"))
  ;; (setenv "CONDA_PREFIX" (convert-standard-filename (subst-char-in-string ?/ ?\\ (conda-env-current-dir))))
  (setenv "CONDA_DEFAULT_ENV" conda-env-current-name)
  (setq elpy-rpc-python-command (executable-find "pythonw.exe")))

(defun conda-rm-env-postdeactivate-func ()
  "Remove environment variables post deactivation."
  (setenv "CONDA_SHLVL" "0")
  (setenv "CONDA_PROMPT_MODIFIER")
  (setenv "CONDA_PREFIX")
  (setenv "CONDA_DEFAULT_ENV")
  (setq elpy-rpc-python-command (executable-find "pythonw.exe")))

(if (is-windows)
    (use-package conda
      :disabled
      :pin melpa
      :ensure t
      :init
      (setq conda-anaconda-home (get-conda-root)
            conda-postactivate-hook 'conda-add-env-postactivate-func
            conda-postdeactivate-hook 'conda-rm-env-postdeactivate-func)
      :config
      (conda-env-initialize-interactive-shells)
      (conda-env-initialize-eshell)))
