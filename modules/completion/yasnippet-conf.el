(use-package auto-yasnippet
  :ensure t
  :pin melpa
  )

(use-package yasnippet
  :diminish yas-minor-mode
  :commands yas-minor-mode
  :config (yas-reload-all))

(use-package yasnippet-snippets
  :ensure t
  :pin melpa
  )
