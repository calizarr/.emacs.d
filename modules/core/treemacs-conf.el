;; Add in treemacs
(use-package treemacs
  :ensure t
  :defer t
  )

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package treemacs-icons-dired
  :after treemacs dired
  :ensure t
  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)

(use-package lsp-treemacs
  :ensure t
  :defer t
  :after treemacs lsp-mode lsp-ui company-lsp)
