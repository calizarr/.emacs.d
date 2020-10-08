(use-package lsp-mode
  :ensure t
  :pin melpa
  :bind (("C-c C-v t" . lsp-describe-type-at-point)
         ("C-c C-r t" . lsp-describe-thing-at-point)
         ("C-c C-l" . lsp)
         ;; (:map lsp-mode-map ("C-c C-l" . hydra-lsp/body))
         )
  :hook
  (scala-mode . lsp-deferred)
  (sh-mode .lsp-deferred)
  (go-mode . lsp-deferred)
  (terraform-mode . lsp-deferred)
  (lsp-mode . lsp-lens-mode)
  :commands (lsp lsp-deferred)
  :config (setq lsp-prefer-flymake nil
                lsp-modeline-diagnostics-scope :project
                lsp-headerline-breadcrumb-enable t
                lsp-headerline-breadcrumb-enable-symbol-numbers t))

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))

(use-package lsp-ui
  :ensure t
  :pin melpa
  :bind (("C-c C-v s" . lsp-ui-sideline-toggle-symbols-info)
         ("C-c C-v d" . lsp-ui-doc-mode)
         ("C-c M-i" . lsp-ui-imenu))
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-sideline-ignore-duplicate t
        lsp-ui-flycheck-enable t
        lsp-ui-doc-include-signature t
        ))

;; (setq lsp-print-io t)

(use-package helm-lsp
  :ensure t
  :requires helm
  :after helm
  :commands helm-lsp-workspace-symbol)

;; (use-package company-lsp
;;   :ensure t
;;   :pin melpa)

(use-package lsp-treemacs
  :ensure t
  :commands lsp-treemacs-errors-list
  :pin melpa
  :defer t
  :after treemacs lsp-mode lsp-ui company-lsp)

(use-package lsp-metals
  :config (setq lsp-metals-treeview-show-when-views-received t))

(use-package which-key
  :config
  (which-key-mode))

;; (push 'company-lsp company-backends)

(defun lsp-describe-type-at-point ()
  "Display the full documentation of the thing at point."
  (interactive)
  (let ((contents (-some->> (lsp--text-document-position-params)
                    (lsp--make-request "textDocument/hover")
                    (lsp--send-request)
                    (gethash "contents"))))
    (if (and contents (not (equal contents "")) )
        (lsp--info (lsp--render-on-hover-content contents t))
      (lsp--info "No content at point."))))

;; Bash LSP Settings
;; https://github.com/mads-hartmann/bash-language-server#emacs
;; (setq lsp-bash-highlight-parsing-errors t)

;; Use the Debug Adapter Protocol for running tests and debugging
(use-package posframe
  ;; Posframe is a pop-up tool that must be manually installed for dap-mode
  )
(use-package dap-mode
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode)
  )

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

