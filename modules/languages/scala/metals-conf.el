;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :init (global-flycheck-mode))

(use-package lsp-mode
  :ensure
  :pin melpa
  :init (setq lsp-prefer-flymake nil))

(use-package lsp-ui
  :ensure
  :pin melpa
  :hook (lsp-mode . lsp-ui-mode))

(use-package helm-lsp
  :ensure t)

(use-package lsp-scala
  :after scala-mode
  :demand t
  ;; Optional - enable lsp-scala automatically in scala files
  :hook (scala-mode . lsp)
  )

(use-package company-lsp
  :ensure t)
(push 'company-lsp company-backends)

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
                            "org.scalameta:metals_2.12:0.5.0"
                            "-r bintray:scalacenter/releases"
                            "-r sonatype:snapshots"
                            "-o /usr/local/bin/metals-emacs -f") " "))
       ;; The java command to run the coursier download (OS agnostic)
       (command "java -noverify -jar coursier bootstrap"))
    ;; Check if it already exists.
    (if (not (file-exists-p "/usr/local/bin/metals-emacs"))
        ;; Check if we're not in Windows
        (if (not (string-equal system-type "windows-nt"))
            (progn
              (shell-command (format "bash -c %s" (shell-quote-argument "curl -L -o coursier https://git.io/coursier")))
              (shell-command (format "bash -c %s" (shell-quote-argument "chmod +x coursier")))
              (shell-command (format "bash -c %s" (shell-quote-argument (concat command " " args)))))
          ;; If we're in Windows we use Powershell
          (progn
            (shell-command (format "powershell %s" "curl -o coursier https://git.io/coursier"))
            (shell-command (concat command " " args))))
      ;; Otherwise, we don't do anything if it already exists
      (message "metals-emacs binary already exists"))))

(install-metals)
