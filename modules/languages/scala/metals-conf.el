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
                            "org.scalameta:metals_2.12:0.7.6"
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
              (let ((default-directory "/sudo::"))
                (shell-command (format "bash -c %s" (shell-quote-argument "curl -L -o coursier https://git.io/coursier")))
                (shell-command (format "bash -c %s" (shell-quote-argument "chmod +x coursier")))
                (shell-command (format "bash -c %s" (shell-quote-argument (concat command " " args))))
                (shell-command (format "bash -c %s" (shell-quote-argument "rm coursier")))))
          ;; If we're in Windows we use Powershell
          (progn
            (shell-command (format "powershell %s" "curl -o coursier https://git.io/coursier"))
            (shell-command (concat command " " args))
            (shell-command (format "powershell %s" "rm coursier"))))
      ;; Otherwise, we don't do anything if it already exists
      (message "metals-emacs binary already exists"))))

(install-metals)
