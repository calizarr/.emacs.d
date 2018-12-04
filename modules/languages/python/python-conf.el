;; (setq python-shell-completion-native-enable nil)

(add-hook 'python-mode-hook (lambda ()
                              (require 'sphinx-doc)
                              (sphinx-doc-mode t)))

;; When entering ensime-mode, consider also the snippets in the
;; snippet table "scala-mode"
(add-hook 'python-mode-hook
          #'(lambda ()
              (yas-activate-extra-mode 'python-mode)))
