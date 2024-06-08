;; Dashboard
(use-package page-break-lines
  :demand
  :straight t)

(setq dashboard-banner-logo-title "Welcome back calizarr!")

(setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
                        (projects . 5)
                        (agenda . 5)
                        (registers . 5)))

(use-package dashboard
  :demand
  :straight t
  :config (dashboard-setup-startup-hook))
