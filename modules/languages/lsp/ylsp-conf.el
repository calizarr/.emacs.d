;; LSP Yaml mode
(setq lsp-yaml-schemas (make-hash-table)
      lsp-yaml-schema-store-enable t
      lsp-yaml-schema-store-uri "https://www.schemastore.org/api/json/catalog.json")

;; Filling the schemas in
(puthash "https://json.schemastore.org/kustomization" "/kustomization.yaml" lsp-yaml-schemas)
(puthash "kubernetes" "/*-k8s.yaml" lsp-yaml-schemas)
;; (puthash "https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.15.7-standalone-strict/all.json" "/*-k8s.yaml" lsp-yaml-schemas)

(defvar ylsp-modeline "# yaml-language-server: $schema=")

(defun ylsp-operations (modeline)
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (insert modeline "\n"))))

(defun ylsp-kustomize-modeline ()
  "Inserts kustomization modeline at top of buffer"
  (interactive)
  (let ((modeline (concat ylsp-modeline "https://json.schemastore.org/kustomization\n")))
    (ylsp-operations modeline)))

(defun ylsp-k8s-modeline (name)
  "Inserts the kubernetes modeline at the top of the buffer"
  (interactive "MName of k8s Kind: ")
  (let* ((url "https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.15.7-standalone-strict/")
         (modeline (concat ylsp-modeline url name)))
    (ylsp-operations modeline)))

(defun ylsp-generic-modeline (url)
  "Inserts a yaml schema modeline using url"
  (interactive "MUrl that contains the schema: ")
  (let ((modeline (concat ylsp-modeline url)))
    (ylsp-operations modeline)))

(defun ylsp-ext-change ()
  (interactive)
  (async-shell-command "fd -e yaml -p -j1 -x bash -c 'old_name=\"{}\" new_name=$(echo $old_name | sed \"s/.yaml/-k8s.yaml/\") && git mv $old_name $new_name'"))

(defun ylsp-ext-change-back ()
  (interactive)
  (async-shell-command "fd -e yaml -p -j1 -x bash -c 'old_name=\"{}\" new_name=$(echo $old_name | sed \"s/-k8s.yaml/.yaml/\") && git mv $old_name $new_name'"))

;;

