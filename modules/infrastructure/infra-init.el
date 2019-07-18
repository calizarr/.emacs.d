;; Load Prodigy File
(load "prodigy-conf.el")
;; Load Dockerfile Mode
(use-package dockerfile-mode
  :ensure t)
;; Load Groovy Mode
(use-package groovy-mode
  :ensure t
  :init
  (setq groovy-indent-offset 2))
