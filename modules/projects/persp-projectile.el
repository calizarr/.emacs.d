(use-package perspective
  :ensure t
  :init (persp-mode))

(use-package persp-projectile
  :ensure t
  :config
  (define-key projectile-mode-map (kbd "s-x") 'projectile-persp-switch-project)
  (define-key projectile-mode-map (kbd "s-s") 'persp-switch))
