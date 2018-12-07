(use-package perspective
  :ensure)

(persp-mode)
(use-package persp-projectile
  :ensure)
(define-key projectile-mode-map (kbd "s-x") 'projectile-persp-switch-project)
(define-key projectile-mode-map (kbd "s-s") 'persp-switch)
