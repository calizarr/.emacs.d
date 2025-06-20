;; -*- lexical-binding: t; -*-

;; Setting up powerline etc.
(use-package smart-mode-line-powerline-theme
  :ensure t)

(use-package smart-mode-line
  :ensure t
  :init
  (setq powerline-arrow-shape 'curve
        powerline-default-separator-dir '(right . left)
        sml/theme 'light-powerline
        sml/no-confirm-load-theme t)
  (sml/setup))
