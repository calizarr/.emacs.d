;; the package manager
(require 'package)
(setq
 package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                    ("org" . "http://orgmode.org/elpa/")
                    ("melpa" . "http://melpa.org/packages/")
                    ("melpa-stable" . "http://stable.melpa.org/packages/"))
 package-archive-priorities '(("melpa-stable" . 1)))

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; Changing prompt to y/n instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; global variables
(setq
 inhibit-startup-screen t
 create-lockfiles nil
 make-backup-files nil
 column-number-mode t
 scroll-error-top-bottom t
 show-paren-delay 0.5
 use-package-always-ensure t
 sentence-end-double-space nil)

;; buffer local variables
(setq-default
 indent-tabs-mode nil
 tab-width 4
 c-basic-offset 4)

;; global keybindings
(global-unset-key (kbd "C-z"))

;; Comment out / uncomment region
(defun comment-or-uncomment-line-or-region ()
  "Comments or uncomments the current line or region."
  (interactive)
  (if (region-active-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    )
  )
(global-set-key (kbd "C-c ;") 'comment-or-uncomment-line-or-region)

;; Don't auto-fill paragraphs with spaces
(auto-fill-mode 0)

;;Show Parentheses!
(show-paren-mode t)

;; Removing annoying alarm bell.
(setq visible-bell 1)

;; Window Undo!
(when (fboundp 'winner-mode)
  (winner-mode 1))

;; Making a previous window command
(global-set-key (kbd "C-x p") (kbd "C-u -1 C-x o"))

;; Add a beacon!
(use-package beacon
  :demand
  :ensure t
  :config (beacon-mode 1))
