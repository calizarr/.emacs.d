;;; Version Control Settings such as magit etc.

(use-package magit
  :ensure t
  :pin melpa
  :bind (("C-x g" . #'magit-status)))

(use-package forge
  :ensure t
  :pin melpa
  :after magit)
