;; Set this first to speed up startup 5.5s -> 2.5s
(setq gc-cons-threshold 200000000) ;; 200 MB of RAM
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq comp-deferred-compilation t)

;; the package manager
(setq package-enable-at-startup nil)

;; Install Straight
(defvar bootstrap-version)

(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install and Setup Use Package, using Straight
(straight-use-package 'use-package)

;; Enable defer and ensure by default for use-package
;; Keep auto-save/backup files separate from source code:  https://github.com/scalameta/metals/issues/1027
(setq use-package-always-defer t
      straight-use-package-by-default t ;; Equivalent to always use ensure but for straight
      backup-directory-alist `((".*" . ,temporary-file-directory))
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

(defvar custom-lisp
  (concat user-emacs-directory
          (convert-standard-filename "custom-lisp/")))

(defvar cal-modules
  (concat user-emacs-directory
          (convert-standard-filename "modules/"))
  "Directory containing personal settings in a modular format.")

;; Custom built / Stack Overflow Etc Settings
(add-to-list 'load-path cal-modules)
(let ((default-directory cal-modules))
  (normal-top-level-add-subdirs-to-load-path))

(add-to-list 'load-path custom-lisp)
(let ((default-directory custom-lisp))
  (normal-top-level-add-subdirs-to-load-path))

;; Load Individual Modules
(require 'core-init)
(require 'appearance-init)
(require 'completion-init)
(require 'projects-init)
(require 'lsp-init)
(require 'python-init)
(require 'scala-init)
(require 'frontend-init)
(require 'elisp-init)
(require 'http-init)
(require 'infra-init)
(require 'go-init)
(require 'tla-init)
(require 'alloy-init)
(require 'kotlin-init)

;;; FOOTER
