;;; completion-init -- Provides settings for completion and narrowing frameworks
;;; Commentary:

;;; Code:
;; Load Company Configuration
(load "company-conf.el")
;; Add in helm settings
(load "helm-conf.el")
;; Add in yasnippet settings
(load "yasnippet-conf.el")

;; Load Ido Configuration
;; (load "ido-conf.el")

(provide 'completion-init)
;;; completion-init ends here
