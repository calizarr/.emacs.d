(use-package auto-yasnippet
  :straight t
  :pin melpa
  )

(use-package yasnippet
  :straight t
  :diminish yas-minor-mode
  :commands yas-minor-mode
  :hook ((go-mode . yas-minor-mode)
         (yaml-mode . yas-minor-mode))
  :config (yas-reload-all))

(require 'yasnippet)

(use-package yasnippet-snippets
  :straight t
  :pin melpa
  )
