(defun format-scala-code ()
  "Hook to run scalafmt on save if prodigy is running."
  (when (eq major-mode 'scala-mode)
    (when (get-buffer "*prodigy*")
    (progn
      (message
       (shell-command-to-string
    (format "/usr/local/Cellar/nailgun/1.0.0/bin/ng org.scalafmt.cli.Cli --exclude .ensime %s" buffer-file-name)))
      (revert-buffer :ignore-auto :noconfirm)))))

(add-hook 'after-save-hook #'format-scala-code)
