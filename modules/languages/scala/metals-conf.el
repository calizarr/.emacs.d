;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :init (global-flycheck-mode))

(use-package lsp-mode
  :ensure t
  :pin melpa
  :bind (("C-c C-v t" . lsp-describe-type-at-point)
         ("C-c C-r t" . lsp-describe-thing-at-point))
  :hook (scala-mode . lsp)
  :config (setq lsp-prefer-flymake nil)
  )

(use-package lsp-ui
  :ensure t
  :pin melpa
  :bind (("C-c C-v s" . lsp-ui-sideline-toggle-symbols-info)
         ("C-c C-v d" . lsp-ui-doc-mode)
         ("C-c M-i" . lsp-ui-imenu))
  :config
  (setq lsp-ui-sideline-ignore-duplicate t
        lsp-ui-flycheck-enable t
        lsp-ui-doc-include-signature t
        ))



;; (use-package lsp-ui
;;   :ensure t
;;   :commands lsp-ui-mode
;;   :hook (lsp-mode . lsp-ui-mode)
;;   :bind (("C-c C-v s" . lsp-ui-sideline-toggle-symbols-info)
;;          ("C-c C-v d" . lsp-ui-doc-mode))
;;   :config
;;   (setq lsp-ui-sideline-enable t
;;         lsp-ui-sideline-ignore-duplicate t
;;         lsp-ui-sideline-show-code-actions t
;;         lsp-ui-sideline-show-diagnostics t
;;         lsp-ui-sideline-show-hover nil
;;         lsp-ui-flycheck-enable t
;;         lsp-ui-flycheck-live-reporting nil
;;         lsp-ui-peek-enable t
;;         lsp-ui-peek-list-width 60
;;         lsp-ui-peek-peek-height 25
;;         lsp-ui-imenu-enable t
;;         lsp-ui-doc-enable t
;;         lsp-ui-doc-include-signature t
;;         lsp-ui-doc-position 'top
;;         lsp-ui-doc-use-childframe t))

;; (setq lsp-print-io t)

(use-package helm-lsp
  :ensure t)

(use-package company-lsp
  :ensure t
  :pin melpa
  )

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

(defun lsp-scala-add-type-annotation ()
  "Add type annotation to the val at point."
  (interactive)
  (lsp-describe-thing-at-point))

;; Printing server I/O for debugging
;; (setq 'lsp-print-io t)

;; Install Metals Binary if not existing
;; I also had previously:
;; "--java-opt \"-XX:+UseG1GC\""
;; "--java-opt \"-XX:+UseStringDeduplication\""

(defun install-metals ()
  "This will install metals hopefully easily."
  (let
      ;; Define the arguments to coursier
      ((args (string-join '(
                            "--java-opt \"-Xss4m\""
                            "--java-opt \"-Xms100m\""
                            "--java-opt \"-Dmetals.client=emacs\""
                            "org.scalameta:metals_2.12:0.7.0"
                            "-r bintray:scalacenter/releases"
                            "-r sonatype:snapshots"
                            "-o /usr/local/bin/metals-emacs -f") " "))
       ;; The java command to run the coursier download (OS agnostic)
       (command "java -noverify -jar coursier bootstrap"))
    ;; Check if it already exists.
    (if (not (file-exists-p "/usr/local/bin/metals-emacs"))
        ;; Check if we're not in Windows
        (if (not-windows)
            (progn
              (shell-command (format "bash -c %s" (shell-quote-argument "curl -L -o coursier https://git.io/coursier")))
              (shell-command (format "bash -c %s" (shell-quote-argument "chmod +x coursier")))
              (shell-command (format "bash -c %s" (shell-quote-argument (concat command " " args))))
              (shell-command (format "bash -c %s" (shell-quote-argument "rm coursier"))))
          ;; If we're in Windows we use Powershell
          (progn
            (shell-command (format "powershell %s" "curl -o coursier https://git.io/coursier"))
            (shell-command (concat command " " args))
            (shell-command (format "powershell %s" "rm coursier"))))
      ;; Otherwise, we don't do anything if it already exists
      (message "metals-emacs binary already exists"))))

(install-metals)
