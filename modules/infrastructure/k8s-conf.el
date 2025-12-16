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

(defun cal/shell-command-completions (prompt command default)
  (let* ((candidates command))
    (completing-read prompt candidates nil t default)))

(defun kustomize-build ()
  "Run kustomize build on current directory"
  (interactive)
  (compile "kustomize build ."))

(defun kustomize-apply ()
  "Run kustomize apply on current directory in given namespace"
  (interactive)
  (let* ((current-namespace (shell-command-to-string "kubectl config view --minify --output 'jsonpath={..namespace}'"))
         (candidates (split-string (shell-command-to-string "kubectl get namespaces -o jsonpath='{..metadata.name}'")))
         (final-candidates (cons current-namespace candidates))
         (selection (completing-read "Namespace: " final-candidates nil t current-namespace nil nil nil)))
    (compile (format "kustomize build . | kubectl -n %s apply -f -" selection))))
