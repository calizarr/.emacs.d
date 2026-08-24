;; -*- lexical-binding: t; -*-

;;; Server settings -- one socket per GUI instance.

;; The long-running `--fg-daemon' owns the default "server" socket, and a GUI
;; Emacs started from Emacs.app starts no server at all. So a plain `emacsclient'
;; from any subprocess reaches the daemon, whose only frame is a headless tty
;; frame -- anything displayed there is invisible, which is why buffer-display
;; from a shell script silently did nothing.
;;
;; Naming this instance's socket after its PID avoids both the daemon and any
;; sibling GUI instance, which would otherwise fight over a shared name.
;;
;; Exporting the name is the part that makes it usable: the environment
;; propagates down to terminals and to claude-code-ide's subprocesses, so a child
;; can address THIS Emacs by name instead of guessing which socket is live.
;; `~/.emacs.d/bin/emacs-output' reads EMACS_SERVER_NAME for exactly that.

(unless (daemonp)
  (require 'server)
  (setq server-name (format "gui-%d" (emacs-pid)))
  (unless (server-running-p server-name)
    (server-start))
  (setenv "EMACS_SERVER_NAME" server-name))