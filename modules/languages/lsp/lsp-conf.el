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
                lsp-headerline-breadcrumb-enable-symbol-numbers t)
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map))

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

;; TODO: Add hydra/transient to which-key itself
(use-package which-key
  :ensure t
  :init
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

(use-package helm-xref
  :ensure t)
