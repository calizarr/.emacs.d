;; -*- lexical-binding: t; -*-

(use-package k8s-mode
  :ensure t
  :hook (k8s-mode . yas-minor-mode)
  :config (setq k8s-indent-offset 2
                k8s-site-docs-url "https://kubernetes.io/docs/reference/generated/kubernetes-api/"
                k8s-search-documentation-browser-function (quote chrome)
                k8s-site-docs-version "v1.25"))

(use-package kubernetes
  :ensure t
  :commands (kubernetes-overview))

(use-package kubel
  :ensure t)
