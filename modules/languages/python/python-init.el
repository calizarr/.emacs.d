;;; python-init --- Provides settings for python IDE style editing
;;; Commentary:

;;; Code:
;; Elpy-settings
;; (load "elpy-conf.el")
;; python configurations
(load "./python-conf.el")
;; Python PYLS (Palantir) LSP Server
(load "./python-pyls-lsp.el")
;; Python Pyright (Microsoft) LSP Server
(load "./python-pyright-lsp.el")

(provide 'python-init)
;;; python-init ends here
