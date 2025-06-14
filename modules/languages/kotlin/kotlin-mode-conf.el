;; Kotlin Mode
(use-package kotlin-mode
  :mode "\\.kt$"
  :hook ((kotlin-mode . show-paren-mode)
         (kotlin-mode . smartparens-mode)
         (kotlin-mode . yas-minor-mode)
         (kotlin-mode . company-mode)         
         )
  )
