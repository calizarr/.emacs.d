;;; Version Control Settings such as magit etc.

(use-package magit
  :ensure t
  :pin melpa
  :bind (("C-x g" . #'magit-status)
         ("C-x C-g" . #'magit-status)))
