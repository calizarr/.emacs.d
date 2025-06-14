;;; graphviz-init --- Provides settings for graphviz
;;; Commentary:

;;; Code:
;; Graphviz configurations
(use-package graphviz-dot-mode
  :ensure t
  :config
  (setq graphviz-dot-indent-width 4))

(provide 'graphviz-init)
;;; graphviz-init ends here
