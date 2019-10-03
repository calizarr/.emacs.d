;; the package manager
(require 'package)

(setq
 package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                    ("org" . "http://orgmode.org/elpa/")
                    ("melpa" . "http://melpa.org/packages/")
                    ("melpa-stable" . "http://stable.melpa.org/packages/"))
 package-archive-priorities '(("melpa-stable" . 20)
                              ("melpa" . 20)
                              ("gnu" . 10))
 )

;; (package-initialize)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; Enable defer and ensure by default for use-package
(setq use-package-always-defer t
      use-package-always-ensure t)

;; Changing prompt to y/n instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; global variables
(setq
 inhibit-startup-screen t
 create-lockfiles nil
 make-backup-files nil
 column-number-mode t
 scroll-error-top-bottom t
 ;; Show Parentheses!
 show-paren-mode t 
 show-paren-delay 0.5
 use-package-always-ensure t
 sentence-end-double-space nil)

;; buffer local variables
(setq-default
 indent-tabs-mode nil
 tab-width 4
 c-basic-offset 4)

;; Global unset keybindings
(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-x C-z"))

;; Global set keybindings
;; Making a previous window command
(global-set-key (kbd "C-x p") (kbd "C-u -1 C-x o"))

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

;; Contextually hungry C-<backspace>
(defun contextual-backspace ()
  "Hungry whitespace or delete word depending on context."
  (interactive)
  (if (looking-back "[[:space:]\n]\\{2,\\}" (- (point) 2))
      (while (looking-back "[[:space:]\n]" (- (point) 1))
        (delete-char -1))
    (cond
     ((and (boundp 'smartparens-strict-mode)
           smartparens-strict-mode)
      (sp-backward-kill-word 1))
     ((and (boundp 'subword-mode) 
           subword-mode)
      (subword-backward-kill 1))
     (t
      (backward-kill-word 1)))))

(global-set-key (kbd "C-<backspace>") 'contextual-backspace)

;; Don't auto-fill paragraphs with spaces
(auto-fill-mode -1)
(remove-hook 'text-mode-hook #'turn-on-auto-fill)

(use-package smartparens
  :diminish smartparens-mode
  :commands
  smartparens-strict-mode
  smartparens-mode
  sp-restrict-to-pairs-interactive
  sp-local-pair
  :init
  (setq sp-interactive-dwim t)
  :config
  (require 'smartparens-config)
  (sp-use-smartparens-bindings)

  (sp-pair "(" ")" :wrap "C-(") ;; how do people live without this?
  (sp-pair "[" "]" :wrap "s-[") ;; C-[ sends ESC
  (sp-pair "{" "}" :wrap "C-{")

  ;; WORKAROUND https://github.com/Fuco1/smartparens/issues/543
  (bind-key "C-<left>" nil smartparens-mode-map)
  (bind-key "C-<right>" nil smartparens-mode-map)

  (bind-key "s-<delete>" 'sp-kill-sexp smartparens-mode-map)
  (bind-key "s-<backspace>" 'sp-backward-kill-sexp smartparens-mode-map))

;; Removing annoying alarm bell.
(setq visible-bell 1)

;; Window Undo!
(when (fboundp 'winner-mode)
  (winner-mode 1))

;; Add a beacon!
(use-package beacon
  :demand
  :ensure t
  :config (beacon-mode 1))

;; Expand-region style
(use-package expand-region
  :commands 'er/expand-region
  :bind ("C-=" . er/expand-region))

;; Convenience functions for checking whether we're in windows or not
(defun not-windows ()
  "Check if OS is not windows, return t if not."
  (not (string-equal system-type "windows-nt")))

(defun is-windows ()
  "Check if OS is windows, return t if it is."
  (string-equal system-type "windows-nt"))

;; Getting rid of tool bar mode.
(tool-bar-mode -1)
(menu-bar-mode -1)
(toggle-scroll-bar -1)
