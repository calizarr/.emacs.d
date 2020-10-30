;;; core-init --- Loads several core / orphaned settings
;;; Commentary:
;;; TODO: Cleanup and move to appropriate files and groups


;;; Code:
;; Must be loaded first
(load "custom-stuff.el")
;; Calendar Configuration
(load "calendar-conf.el")
;; Adding dashboard settings
(load "dashboard-conf.el")
;; Load Dired settings
(load "dired-conf.el")
;; Calendar Framework
(load "calendar-conf.el")
;; Window resizing shortcuts
(load "winres-conf.el")
;; Random Stupid Stuff
(load "random-stupid-stuff.el")
;; Shell & Eshell Configuration
(load "shell-conf.el")
;; Undo-Tree Conf
(load "undo-tree-conf.el")
;; Very Large Files settings
(load "vlf-conf.el")
;; Version Control Settings
(load "version-control.el")
;; Load More Helpful Help Settings
(load "help-conf.el")
;; Load String Manipulation Packages
(load "string-manipulation.el")
;; Load in treemacs
(load "treemacs-conf.el")
;; Load syntax checking (flycheck)
(load "syntax-checking-conf.el")
;; Load org-mode keybindings
(load "org-conf.el")
;; Load mobility conf / movement around buffers
(load "mobility-conf.el")
;; Load other editing conf files (YAML, etc)
(load "editing-conf.el")

(provide 'core-init)
;;; core-init.el ends here
