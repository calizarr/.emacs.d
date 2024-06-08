;; Elpy-Install information
(use-package elpy
  :straight t
  :commands elpy-enable
  :after python
  :config (elpy-enable)
  :init (with-eval-after-load 'python (elpy-enable))
  )

(setq elpy-shell-use-project-root nil)
