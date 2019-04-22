;; modes
;; (electric-indent-mode 0)

;; ENSIME Packge 
(use-package ensime
  :ensure t
  :pin melpa-stable
  :init
  (setq ensime-sbt-command "nil")
  (setq ensime-startup-notification nil)
  (setq ensime-search-interface 'helm)
  )

(require 'ensime)
(require 'ensime-expand-region)
(require 'ensime-vars)
(require 'ensime-eldoc)

;; Add hook for ensime when in scala-mode
;; (add-hook 'scala-mode-hook
;;           (lambda ()
;;             (ensime-mode)))

;; When entering ensime-mode, consider also the snippets in the
;; snippet table "scala-mode"
(add-hook 'ensime-mode-hook
          #'(lambda ()
              (yas-activate-extra-mode 'scala-mode)))

;; (bind-key "s-<delete>" (sp-restrict-c 'sp-kill-sexp) scala-mode-map)
;; (bind-key "s-<backspace>" (sp-restrict-c 'sp-backward-kill-sexp) scala-mode-map)
;; (bind-key "s-<home>" (sp-restrict-c 'sp-beginning-of-sexp) scala-mode-map)
;; (bind-key "s-<end>" (sp-restrict-c 'sp-end-of-sexp) scala-mode-map)

;; (require 'ansi-color)
;; (defun display-ansi-colors ()
;;   (interactive)
;;   (let ((inhibit-read-only t))
;;     (ansi-color-apply-on-region (point-min) (point-max))))

(defun ensime-router (subcmd)
  (interactive)
  "Execute the sbt `run' command for the project."
  (sbt:command (concat "run " subcmd)))

(defun ensime-sbt-do-run-main (&optional args)
  (interactive)
  (let* ((impl-class
            (or (ensime-top-level-class-closest-to-point)
                (return (message "Could not find top-level class"))))
     (cleaned-class (replace-regexp-in-string "<empty>\\." "" impl-class))
     (command (concat "ensimeRunMain" " " cleaned-class)))
    (setq last-main command)
    (sbt:command (concat command args))))

(defun ensime-sbt-do-run-last-main ()
  (interactive)
  (sbt:command last-main))

(defvar last-main nil "last called main method")

;; New function to open all files after ensime loads then close them
(defun ensime-open-all-files-keep-buffers (dir)
  "Open all .scala files for ensime"
(mapc (lambda (f) (save-excursion (find-file f)))
        (directory-files-recursively dir ".scala$")))

(defun ensime-open-all-files-close-buffers (dir)
  (mapc (lambda (f)
          (save-excursion
            (find-file f)
            (sleep-for 10)
            (kill-buffer (current-buffer))))
        (directory-files-recursively dir ".scala$")))

