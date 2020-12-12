;;; completion-init -- Provides settings for completion and narrowing frameworks
;;; Commentary:

;;; Code:

;; Use hippie-expand instead of dabbrev-expand
(global-set-key (kbd "M-/") 'hippie-expand)

;; Load Company Configuration
(load "./company-conf.el")
;; Add in helm settings
(load "./helm-conf.el")
;; Load helm-rg conf for Windows overrides
(load "./helm-rg-conf.el")
;; Add in yasnippet settings
(load "./yasnippet-conf.el")

;; Load Ido Configuration
;; (load "ido-conf.el")

(provide 'completion-init)
;;; completion-init ends here
