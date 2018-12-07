(defun format-scala-code ()
  (when (eq major-mode 'scala-mode)
    (progn      
      (message
       (shell-command-to-string
    (format "/usr/local/Cellar/nailgun/1.0.0/bin/ng org.scalafmt.cli.Cli --exclude .ensime %s" buffer-file-name)))
      (revert-buffer :ignore-auto :noconfirm))))

(add-hook 'after-save-hook #'format-scala-code)
