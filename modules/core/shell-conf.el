(defun helm-eshell-hist-key ()
  (eshell-cmpl-initialize)
  (define-key eshell-mode-map [remap eshell-pcomplete] 'helm-esh-pcomplete)
  (define-key eshell-mode-map (kbd "M-p") 'helm-eshell-history))

(defun helm-eshell-hist ()
  (define-key eshell-mode-map
    (kbd "M-p")
    'helm-eshell-history))

(use-package eshell
  :init
  (add-hook 'eshell-mode-hook 'helm-eshell-hist-key)
  (add-hook 'eshell-mode-hook 'helm-eshell-hist)
  )

(use-package fish-mode
  :ensure)

;; Remove shell command echo
(defun my-comint-init ()
  (setq comint-process-echoes t))
(add-hook 'comint-mode-hook 'my-comint-init)
