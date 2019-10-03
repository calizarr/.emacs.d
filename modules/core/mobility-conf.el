(use-package avy
  :ensure t
  :bind (("C-'" . avy-goto-char-2)
         ("C-;" . avy-goto-char)
         ("M-g g" . avy-goto-line )
         ("M-g M-g" . avy-goto-line)
         ("M-g w" . avy-goto-word-1)
         ("M-g e" . avy-goto-word-0)
         )
  :config
  (setq avy-all-windows nil
        avy-style 'pre
        ))

(use-package ace-window
  :ensure t
  :bind (("C-c o" . ace-window)
         )
  )
