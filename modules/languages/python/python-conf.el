;; (setq python-shell-completion-native-enable nil)

(use-package sphinx-mode
  :ensure)

(use-package sphinx-doc
  :ensure)

(add-hook 'python-mode-hook (lambda ()
                              (require 'sphinx-doc)
                              (sphinx-doc-mode t)))

;; When entering ensime-mode, consider also the snippets in the
;; snippet table "scala-mode"
(add-hook 'python-mode-hook
          #'(lambda ()
              (yas-activate-extra-mode 'python-mode)))

(use-package pyenv-mode
  :ensure)

