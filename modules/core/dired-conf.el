;; -*- lexical-binding: t; -*-

(use-package dired
  :ensure nil
  :config
  ;; Dired Mode Settings
  (setq dired-recursive-copies 'always
        dired-recursive-deletes 'always
        dired-dwim-target t
        dired-listing-switches "-alh"))

(add-hook 'dired-load-hook
	  (lambda ()
	    (load "dired-x")
	    ;; Set dired-x global variables here.  For example:
            ;; (setq dired-guess-shell-gnutar "gtar")
            ;; (setq dired-x-hands-off-my-keys nil)
	    ))
(add-hook 'dired-mode-hook
          (lambda ()
            ;; Set dired-x buffer-local variables here.  For example:
            ;; (dired-omit-mode 1)
            (treemacs-icons-dired-mode 1)
            ))
