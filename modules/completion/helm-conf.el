;; Helm
(use-package helm
  :demand
  :ensure t
  :commands (helm-M-x helm-find-files)
  :bind (
         ("M-x" . helm-M-x)
         ("C-x C-f" . helm-find-files)
         ("C-x b" . helm-mini)
         ("M-y" . helm-show-kill-ring)
         )
  :init (require 'helm-config)
  :init
  (setq helm-mode-fuzzy-match t
        helm-completion-in-region-fuzzy-match t
        helm-split-window-inside-p t
        helm-display-line-numbers-mode t
        )
  :config (helm-mode 1))

(use-package dash
  :demand
  :ensure t
  )
