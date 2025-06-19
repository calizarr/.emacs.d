(use-package company
  :ensure t
  :diminish company-mode
  :commands company-mode
  :init
  (setq
   company-dabbrev-ignore-case nil
   company-dabbrev-code-ignore-case nil
   company-dabbrev-downcase nil
   company-idle-delay 0
   company-minimum-prefix-length 2)
  (add-hook 'after-init-hook 'global-company-mode)

  :config
  ;; ;; disables TAB in company-mode, freeing it for yasnippet
  (define-key company-active-map [tab] nil)
  (define-key company-active-map (kbd "TAB") nil)
  (add-to-list 'company-backends '(company-jedi company-restclient))
  :bind (:map company-mode-map
              ("C-'" . #'company-complete)
         :map company-active-map
               ("C-'" . #'company-complete)

(use-package company-quickhelp
  :ensure t
  :requires company
  :after company
  :commands (company-quickhelp-manual-begin)
  :bind (:map company-active-map
              ("C-c h" . #'company-quickhelp-manual-begin))
  :init (add-hook 'company-mode-hook 'company-quickhelp-mode))


(use-package company-jedi
  :ensure t
  :requires company)

(use-package company-restclient
  :ensure t)

(use-package company-box
  :ensure t
  :defer t
  :hook (company-mode . company-box-mode))
