;; -*- lexical-binding: t; -*-

;;; http-init --- Provides settings for REST API usage and HTTP in general
;;; Commentary:

;;; Code:
;; Load HTTP configurations
(load "restclient-conf.el")
;; (load "urlpackage-conf.el")
(load "nginx-conf.el")

;; Ensure know-your-http-well
(use-package know-your-http-well
  :ensure)

(provide 'http-init)
;;; http-init ends here
