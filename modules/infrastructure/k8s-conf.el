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

(use-package kubed
  :ensure t)

(defun cal/k8s-current-namespace ()
  "Gets the current namespace and returns it as a string"
  (shell-command-to-string "kubectl config view --minify --output 'jsonpath={..namespace}'"))

(defun cal/k8s-get-namespaces ()
  "Gets all the namespaces and returns them as a list" (split-string (shell-command-to-string "kubectl get namespaces -o jsonpath='{..metadata.name}'")))

(defun cal/k8s-namespace ()
  (let* ((current-namespace (cal/k8s-current-namespace))
         (candidates (cal/k8s-get-namespaces))
         (final-candidates (cons current-namespace candidates))
         (selection (completing-read "Namespace: " final-candidates nil t current-namespace nil nil nil)))
    selection))

(defun cal/kustomize-build ()
  "Run kustomize build on current directory"
  (interactive)
  (if (y-or-n-p "Exclude CRDS?")
      (compile "kustomize build . | yq ea 'select(.kind!=\"CustomResourceDefinition\")'")
    (compile "kustomize build .")))

(defun cal/kustomize-apply ()
  "Run kustomize apply on current directory in given namespace"
  (interactive)
  (let* ((selection (cal/k8s-namespace))
         (apply-string (cal/helm-apply-string selection)))
    (compile (format "kustomize build . %s" apply-string))))

(defun cal/kustomize-delete ()
  "Run kustomize build -> delete on current directory in chosen namespace"
  (interactive)
  (let ((namespace (cal/k8s-namespace)))
    (compile (format "kustomize build . | kubectl --namespace %s delete -f -" namespace))))

(defun cal/helm-template-string (&optional dir)
  "Create the helm template string"
  (let* ((dir (unless dir default-directory))
         (helm-values (string-join (mapcar (lambda (x) (format "-f %s" x)) (directory-files-recursively dir "values.*\\.yaml")) " "))
         (include-crds (if (y-or-n-p "Include CRDS?") "--include-crds " ""))
         (selection (cal/k8s-namespace))
         (release-name (read-string "Release Name: " selection selection selection))
         (helm-string (format "helm template %s--namespace %s %s . %s" include-crds selection release-name helm-values)))
    helm-string))

(defun cal/helm-apply-string (namespace)
  "Create the extra kubectl apply string for helm"
  (let ((normal-apply (format " | kubectl apply --namespace %s" namespace)))
    (if (y-or-n-p "Apply templates?")
        (if (y-or-n-p "Server-side apply?")
            (concat normal-apply " --server-side -f -")
          (concat normal-apply " -f -")))))

(defun cal/helm-template ()
  "Run helm template with args to view yamls"
  (interactive)
  (let* ((helm-string (cal/helm-template-string))
         (namespace (when (string-match "--namespace[[:space:]]\\([a-zA-Z0-9-]+\\)[[:space:]][a-zA-Z]" helm-string) (match-string 1 helm-string)))
         (helm-apply (cal/helm-apply-string namespace)))
    (compile (format "%s %s" helm-string (if helm-apply helm-apply "")))))

(defun cal/helm-delete ()
  "Run helm template to delete resources"
  (interactive)
  (let* ((helm-string (cal/helm-template-string))
         (namespace (when (string-match "--namespace[[:space:]]\\([a-zA-Z0-9-]+\\)[[:space:]][a-zA-Z]" helm-string) (match-string 1 helm-string))))
    (compile (format "%s %s" helm-string (format " | kubectl --namespace %s delete -f -" namespace)))))
