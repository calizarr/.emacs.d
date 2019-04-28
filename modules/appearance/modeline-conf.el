;; Setting up powerline etc.
(use-package smart-mode-line
  :ensure t)

(use-package smart-mode-line-powerline-theme
  :ensure t)

;; These two lines are just examples
(setq powerline-arrow-shape 'curve)
(setq powerline-default-separator-dir '(right . left))
(setq sml/theme 'light-powerline)
(sml/setup)
