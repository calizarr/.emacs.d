;; Set this first to speed up startup 5.5s -> 2.5s
(setq gc-cons-threshold (expt 2 24)) ;; 16mb instead of 800k
(setq comp-deferred-compilation t)

;; the package manager
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("melpa" . "http://melpa.org/packages/")
                         ("melpa-stable" . "http://stable.melpa.org/packages/"))
      package-archive-priorities '(("melpa-stable" . 20)
                                   ("melpa" . 20)
                                   ("gnu" . 10)))

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; Enable defer and ensure by default for use-package
;; Keep auto-save/backup files separate from source code:  https://github.com/scalameta/metals/issues/1027
(setq use-package-always-defer t
      use-package-always-ensure t
      backup-directory-alist `((".*" . ,temporary-file-directory))
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

(defvar cal-modules
  (concat user-emacs-directory
          (convert-standard-filename "modules/"))
  "Directory containing personal settings in a modular format.")

;; Custom built / Stack Overflow Etc Settings
(add-to-list 'load-path cal-modules)
(let ((default-directory cal-modules))
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

;;; FOOTER
