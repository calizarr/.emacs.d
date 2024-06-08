(use-package k8s-mode
  :straight t
  :hook (k8s-mode . yas-minor-mode)
  :config (setq k8s-indent-offset nil
                k8s-site-docs-url "https://kubernetes.io/docs/reference/generated/kubernetes-api/"
                k8s-search-documentation-browser-function (quote chrome)
                k8s-site-docs-version "v1.15"))

(use-package kubernetes
  :straight t
  :commands (kubernetes-overview))

(use-package kubel
  :straight t)
