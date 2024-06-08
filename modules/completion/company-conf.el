(use-package company
  :straight t
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
              ("C-:" . #'helm-company)
         :map company-active-map
               ("C-'" . #'company-complete)
               ("C-:" . #'helm-company)))

(use-package company-quickhelp
  :straight t
  :requires company
  :after company
  :commands (company-quickhelp-manual-begin)
  :bind (:map company-active-map
              ("C-c h" . #'company-quickhelp-manual-begin))
  :init (add-hook 'company-mode-hook 'company-quickhelp-mode))


(use-package company-jedi
  :straight t
  :requires company)

(use-package helm-company
  :straight t
  :defer t
  :requires helm company
  :after helm company
  :init
  ;; Not necessary if using ELPA package
  (autoload 'helm-company "helm-company"))


(use-package company-restclient
  :straight t)

(use-package company-box
  :straight t
  :defer t
  :hook (company-mode . company-box-mode))
