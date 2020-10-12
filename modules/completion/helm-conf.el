;; Helm
(use-package helm
  :demand
  :ensure t
  :preface (require 'helm-config)
  :commands (helm-M-x helm-find-files helm-semantic-or-imenu)
  :bind (
         ("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x b" . helm-mini)
         ("M-y" . helm-show-kill-ring)
         ("M-i" . helm-semantic-or-imenu)
         )
  :init
  (setq helm-mode-fuzzy-match t
        helm-completion-in-region-fuzzy-match t
        helm-split-window-inside-p t
        helm-display-line-numbers-mode t
        )
  :config (helm-mode 1))

(use-package helm-fd
  :ensure t
  :requires helm
  :after helm
  :bind (:map helm-command-map
              ("/" . helm-fd)))

(use-package helm-rg
  :ensure t
  :requires helm
  :after helm)

(use-package dash
  :demand
  :ensure t
  )
