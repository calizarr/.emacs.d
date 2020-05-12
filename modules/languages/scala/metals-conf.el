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
                            "org.scalameta:metals_2.12:0.9.0"
                            "-r bintray:scalacenter/releases"
                            "-r sonatype:snapshots"
                            ,metals-line)
                          " "))
       ;; The java command to run the coursier download (OS agnostic)
       (command "java -noverify -jar coursier bootstrap"))
    ;; Check if it already exists.
    (if (not (file-exists-p metals-path))
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

;; (defvar lsp-mode--title "LSP Mode")

;; (pretty-hydra-define hydra-lsp (:exit t :hint nil :title lsp-mode--title)
;;   ("Buffer"
;;    (("f" lsp-format-buffer "format")
;;     ("m" lsp-ui-imenu "imenu")
;;     ("x" lsp-execute-code-action "execute action"))

;;    "Server"
;;    (("M-s" lsp-describe-session "describe session")
;;     ("M-r" lsp-restart-workspace "restart")
;;     ("S" lsp-shutdown-workspace "shutdown"))

;;    "Symbol"
;;    (("d" lsp-find-declaration "declaration")
;;     ("D" lsp-ui-peek-find-definitions "definition")
;;     ("R" lsp-ui-peek-find-references "references")
;;     ("i" lsp-ui-peek-find-implementation "implementation")
;;     ("t" lsp-find-type-definition "type")
;;     ("s" lsp-signature-help "signature")
;;     ("o" lsp-describe-thing-at-point "documentation")
;;     ("r" lsp-rename "rename"))
;;    ))
   

;; ;; Hydra for LSP-mode
;; (defhydra hydra-lsp (:exit t :hint nil)
;;   "
;;  Buffer^^               Server^^                   Symbol
;; -------------------------------------------------------------------------------------
;;  [_f_] format           [_M-r_] restart            [_d_] declaration  [_i_] implementation  [_o_] documentation
;;  [_m_] imenu            [_S_]   shutdown           [_D_] definition   [_t_] type            [_r_] rename
;;  [_x_] execute action   [_M-s_] describe session   [_R_] references   [_s_] signature"
;;   ("d" lsp-find-declaration)
;;   ("D" lsp-ui-peek-find-definitions)
;;   ("R" lsp-ui-peek-find-references)
;;   ("i" lsp-ui-peek-find-implementation)
;;   ("t" lsp-find-type-definition)
;;   ("s" lsp-signature-help)
;;   ("o" lsp-describe-thing-at-point)
;;   ("r" lsp-rename)

;;   ("f" lsp-format-buffer)
;;   ("m" lsp-ui-imenu)
;;   ("x" lsp-execute-code-action)

;;   ("M-s" lsp-describe-session)
;;   ("M-r" lsp-restart-workspace)
;;   ("S" lsp-shutdown-workspace))
