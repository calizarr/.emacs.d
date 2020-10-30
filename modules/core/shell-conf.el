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

;; Remove shell command echo
(defun my-comint-init ()
  (setq comint-process-echoes t))
(add-hook 'shell-mode-hook 'my-comint-init)

;; Add exec-path-from-shell for OSX

(when (memq window-system '(mac ns x))
  (use-package exec-path-from-shell
    :ensure t
    :pin melpa-stable
    :commands exec-path-from-shell-initialize))

;; (setq ansi-color-faces-vector
;;       [default default default italic underline success warning error]
;;       ansi-color-for-comint-mode t
;;       ansi-color-names-vector
;;       ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
