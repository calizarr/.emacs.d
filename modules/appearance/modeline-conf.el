;; Setting up powerline etc.
(use-package smart-mode-line-powerline-theme
  :straight t)

(use-package smart-mode-line
  :straight t
  :init
  (setq powerline-arrow-shape 'curve
        powerline-default-separator-dir '(right . left)
        sml/theme 'light-powerline
        sml/no-confirm-load-theme t)
  (sml/setup))
