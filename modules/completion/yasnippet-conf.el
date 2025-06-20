;; -*- lexical-binding: t; -*-

(use-package auto-yasnippet
  :ensure t
  :pin melpa
  )

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :commands yas-minor-mode
  :hook ((go-mode . yas-minor-mode)
         (yaml-mode . yas-minor-mode))
  :config (yas-reload-all))

(require 'yasnippet)

(use-package yasnippet-snippets
  :ensure t
  :pin melpa
  )
