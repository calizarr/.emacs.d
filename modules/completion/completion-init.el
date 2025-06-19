;;; completion-init -- Provides settings for completion and narrowing frameworks
;;; Commentary:

;;; Code:

;; Use hippie-expand instead of dabbrev-expand
;; (global-set-key (kbd "M-/") 'hippie-expand)

;; Rebind completion-list-mode-map
(global-set-key (kbd "C-M-g") 'keyboard-escape-quit)
(global-set-key (kbd "C-g") 'keyboard-quit)


;; Load Company Configuration
;; (load "./company-conf.el")
;; Add in yasnippet settings
(load "./yasnippet-conf.el")

;; Load the Vertico Ecosystem => Currently in trying it out mode
(load "./vertico-eco/consult.el")
(load "./vertico-eco/vertico-ecosystem.el")
(load "./vertico-eco/embark.el")
(load "./vertico-eco/orderless.el")
(load "./vertico-eco/corfu.el")
(load "./vertico-eco/vertico-eco-emacs.el")

(provide 'completion-init)
;;; completion-init ends here
