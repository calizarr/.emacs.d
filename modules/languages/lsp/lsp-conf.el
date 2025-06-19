;;; -*- lexical-binding: t -*-
(use-package lsp-mode
  :ensure t
  :pin melpa
  :init
  (setq lsp-keymap-prefix "C-c l")
  :bind (("C-c C-v t" . lsp-describe-type-at-point)
         ("C-c C-r t" . lsp-describe-thing-at-point)
         ("C-c C-l" . lsp))
  :hook
  (scala-mode . lsp-deferred)
  (sh-mode .lsp-deferred)
  (go-mode . lsp-deferred)
  (terraform-mode . lsp-deferred)
  (kotlin-mode . lsp-deferred)
  (lsp-mode . lsp-lens-mode)
  (lsp-mode . lsp-enable-which-key-integration)
  :commands (lsp lsp-deferred)
  :config (setq lsp-prefer-flymake nil
                lsp-idle-delay 0.250
                ;; Set to t for debugging
                lsp-log-io nil
                lsp-modeline-diagnostics-scope :project
                lsp-modeline-code-actions-enable t
                lsp-headerline-breadcrumb-enable t
                lsp-headerline-breadcrumb-enable-symbol-numbers t
                lsp-terraform-ls-enable-show-reference t
                lsp-semantic-tokens-enable t
                lsp-semantic-tokens-enable-multiline-token-support t
                lsp-semantic-tokens-honor-refresh-requests t
                lsp-enable-links t
                lsp-terraform-ls-prefill-required-fields t
                lsp-disabled-clients '(tfls semgrep-ls)
                lsp-use-plists t
                )
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map))

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
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-code-actions t
        ))

;; (setq lsp-print-io t)

;; (use-package helm-lsp
;;   :ensure t
;;   :requires helm
;;   :after helm
;;   :commands helm-lsp-workspace-symbol
;;   :config ((define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol)))

;; (use-package company-lsp
;;   :ensure t
;;   :pin melpa)

(use-package lsp-treemacs
  :ensure t
  :commands lsp-treemacs-errors-list
  :pin melpa
  :defer t
  :after treemacs lsp-mode lsp-ui company-lsp
  :config (lsp-treemacs-sync-mode 1))

(use-package lsp-metals
  :ensure t
  :custom
  ;; Metals claims to support range formatting by default but it supports range
  ;; formatting of multiline strings only. You might want to disable it so that
  ;; emacs can use indentation provided by scala-mode.
  (lsp-metals-server-args '("-J-Dmetals.allow-multiline-string-formatting=off"))
  :hook (scala-mode . lsp-deferred))


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
;; Posframe is a pop-up tool that must be manually installed for dap-mode
(use-package posframe
  :ensure t)

(use-package lsp-docker
  :ensure t)

(use-package dap-mode
  :ensure t
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode))

;; (use-package helm-xref
;;   :ensure t)

(use-package iedit
  :ensure t)
  ;; :hook
  ;; (lsp-mode . iedit-mode))
