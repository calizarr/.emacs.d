(use-package ansible
  :straight t
  :config
  (add-hook 'yaml-mode-hook #'(lambda () (ansible 1)))
  )

(use-package ansible-doc

  :straight t)

(use-package company-ansible
  :straight t)

(use-package poly-ansible
  :straight t)
