;; Configuration file for all things Metals the Scala LSP server
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
  (with-output-to-temp-buffer "*install-metals*"
  (let*
      ;; Define the arguments to coursier
      ((metals-path (convert-standard-filename (expand-file-name ".local/bin/metals-emacs" (getenv "HOME"))))
       (metals-line (concat "-o " metals-path " -f"))
       ;; When quoting a list of strings and you need a variable evaluated, use a backtick (`) quote
       ;; and a comma (,) before the variable you want to evaluate
       (args (string-join `(
                            "--java-opt \"-Xss4m\""
                            "--java-opt \"-Xms100m\""
                            "--java-opt \"-Dmetals.client=emacs\""
                            "org.scalameta:metals_2.12:0.9.4"
                            "-r bintray:scalacenter/releases"
                            "-r sonatype:snapshots"
                            ,metals-line)
                          " "))
       ;; The java command to run the coursier download (OS agnostic)
       (command "java -noverify -jar coursier bootstrap"))
    ;; Check if it already exists.
    (princ (format "The metals-path is: %s\n" metals-path))
    (if (not (file-exists-p metals-path))
        ;; Check if we're not in Windows
        (if (not-windows)
            (progn
              (princ (format "The command that will be used:\n %s\n" (concat command " " args)))
              (princ (shell-command-to-string (format "bash -c %s" (shell-quote-argument "curl -L -o coursier https://git.io/coursier-cli"))))
              (shell-command (format "bash -c %s" (shell-quote-argument "chmod +x coursier")))
              (princ (shell-command-to-string (format "bash -c %s" (shell-quote-argument (concat command " " args)))))
              (shell-command (format "bash -c %s" (shell-quote-argument "rm coursier"))))
          ;; If we're in Windows we use Powershell
          (progn
            (shell-command (format "powershell %s" "curl -o coursier https://git.io/coursier-cli"))
            (shell-command (concat command " " args))
            (shell-command (format "powershell %s" "rm coursier"))))
      ;; Otherwise, we don't do anything if it already exists
      (princ "metals-emacs binary already exists")))
  (pop-to-buffer "*install-metals*")))

(install-metals)
