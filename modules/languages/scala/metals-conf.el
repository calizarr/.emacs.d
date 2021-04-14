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

(defun metals-version-fn ()
  "This will pull the latest metals version via coursier"
  (compile "curl -L -o coursier https://git.io/coursier-cli")
  (shell-command-to-string "java -noverify -jar coursier complete org.scalameta:metals_2.12: | tail -n1 | tr -d '\n'"))

(defun install-metals ()
  "This will install metals hopefully easily."
  (let*
      ;; Define the arguments to coursier
      ((metals-path (convert-standard-filename (expand-file-name ".local/bin/metals-emacs" (getenv "HOME"))))
       (metals-line (concat "-o " metals-path " -f"))
       (metals-version (metals-version-fn))
       (coursier-download "curl -L -o coursier https://git.io/coursier-cli")
       ;; When quoting a list of strings and you need a variable evaluated, use a backtick (`) quote
       ;; and a comma (,) before the variable you want to evaluate
       (args (string-join `(
                            "--java-opt \"-Xss4m\""
                            "--java-opt \"-Xms100m\""
                            "--java-opt \"-Dmetals.client=emacs\""
                            ,(format "org.scalameta:metals_2.12:%s" metals-version)
                            "-r bintray:scalacenter/releases"
                            "-r sonatype:snapshots"
                            ,metals-line)
                          " "))
       ;; The java command to run the coursier download (OS agnostic)
       (command "java -noverify -jar coursier bootstrap")
       (metals-download (concat command " " args)))
    ;; Check if it already exists.
    (if (not (file-exists-p metals-path))
        (progn
          (kill-buffer "*compilation*")
          (compile (string-join (list coursier-download metals-download "rm coursier") " && "))))
    (message "Metals - metals-emacs binary already exists")
    (message "Metals - Checking if it is the latest version...")
    (let ((current-version (shell-command-to-string "metals-emacs --version | head -n1 | awk '{printf $2}'")))
      (if (not (string-equal current-version metals-version))
          (progn
            (kill-buffer "*compilation*")
            (compile (string-join (list coursier-download metals-download "rm coursier") " && "))))
      (message "Metals - Most current version already exists"))))

(install-metals)
