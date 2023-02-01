(use-package ansible
  :ensure t
  :config
  (add-hook 'yaml-mode-hook #'(lambda () (ansible 1)))
  )

(use-package ansible-doc

  :ensure t)

(use-package company-ansible
  :ensure t)

(use-package poly-ansible
  :ensure t)
