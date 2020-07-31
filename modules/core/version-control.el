(use-package magit
  :ensure t
  :pin melpa)

;; Setting C-x g to be magit-status
(global-set-key (kbd "C-x g") (quote magit-status))
