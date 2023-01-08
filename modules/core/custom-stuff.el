;; Have emacs save customize settings not in init.el
(setq custom-file (concat user-emacs-directory (convert-standard-filename "emacs-custom.el")))

(load custom-file :noerror)

;; Test out uniquify different style
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; Removing stuff from custom-set-variables
(global-display-line-numbers-mode t)
(setq desktop-save-mode nil
      ediff-window-setup-function 'ediff-setup-windows-plain
      eide-custom-color-theme 'dark
      load-prefer-newer t
      require-final-newline t
      apropos-do-all t
      eval-expression-print-length nil
      pop-up-frames nil)

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
 show-paren-delay 0.5
 sentence-end-double-space nil)

(show-paren-mode)

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
;; Shrink and enlarge window commands (winres.conf)
(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

;; Comment out / uncomment region
(defun comment-or-uncomment-line-or-region ()
  "Comments or uncomments the current line or region."
  (interactive)
  (if (region-active-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))))
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

;; Removing annoying alarm bell.
(setq visible-bell 1)

;; Window Undo!
(when (fboundp 'winner-mode)
  (winner-mode 1))

;; Getting rid of tool bar mode.
(tool-bar-mode -1)
(menu-bar-mode -1)
(toggle-scroll-bar -1)

;; Changing list buffers (C-x C-b) to ibuffer
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Global eval buffer
(global-set-key (kbd "C-c C-b") 'eval-buffer)

;; Add exec-path-from-shell for OSX and daemon-mode
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize))
  (when (daemonp)
    (exec-path-from-shell-initialize)))


(use-package which-key
  :diminish
  :ensure t
  :init
  (which-key-mode))

(use-package smartparens
  :diminish smartparens-mode
  :commands
  smartparens-strict-mode
  smartparens-mode
  sp-restrict-to-pairs-interactive
  sp-local-pair
  :init
  (setq sp-interactive-dwim t)
  :bind (:map smartparens-mode-map
              ("M-<right>" . #'sp-backward-slurp-sexp)
              ("C-<right>" . #'sp-forward-slurp-sexp)
              ("M-<left>" . #'sp-backward-barf-sexp)
              ("C-<left>" . #'sp-forward-barf-sexp)
              )
  :config
  (require 'smartparens-config)
  (sp-use-smartparens-bindings)

  (sp-pair "(" ")" :wrap "C-(") ;; how do people live without this?
  (sp-pair "[" "]" :wrap "s-[") ;; C-[ sends ESC
  (sp-pair "{" "}" :wrap "C-{")

  ;; WORKAROUND https://github.com/Fuco1/smartparens/issues/543
  ;; Ensime / Fommil bindings
  ;; (bind-key "C-<left>" nil smartparens-mode-map)
  ;; (bind-key "C-<right>" nil smartparens-mode-map)

  (bind-key "s-<delete>" 'sp-kill-sexp smartparens-mode-map)
  (bind-key "s-<backspace>" 'sp-backward-kill-sexp smartparens-mode-map))

;; Expand-region style
(use-package expand-region
  :commands 'er/expand-region
  :bind ("C-=" . er/expand-region))

;; Diminish
(use-package diminish)
(diminish 'auto-revert-mode)

;; Very Large File
(use-package vlf
  :ensure t)

;; Load More Helpful Help Settings
(use-package helpful
  :ensure t
  :bind (
         ;; Note that the built-in `describe-function' includes both functions
         ;; and macros. `helpful-function' is functions only, so we provide
         ;; `helpful-callable' as a drop-in replacement.
         ("C-h f" . #'helpful-callable)
         ("C-h v" . #'helpful-variable)
         ("C-h k" . #'helpful-key)
         ;; Lookup the current symbol at point. C-c C-d is a common keybinding
         ;; for this in lisp modes.
         ("C-c C-d" . #'helpful-at-point)
         ;; Look up *F*unctions (excludes macros).
         ;;
         ;; By default, C-h F is bound to `Info-goto-emacs-command-node'. Helpful
         ;; already links to the manual, if a function is referenced there.
         ("C-h F" . #'helpful-function)
         ;; Look up *C*ommands.
         ;;
         ;; By default, C-h C is bound to describe `describe-coding-system'. I
         ;; don't find this very useful, but it's frequently useful to only
         ;; look at interactive functions.
         ("C-h C" . #'helpful-command)))

;; Emacs String Manipulation libraries
;; https://github.com/magnars/s.el
(use-package s
  :ensure t)

;; Undo Tree Mode
(use-package undo-tree
  :diminish undo-tree-mode
  :init
  (setq undo-tree-history-directory-alist (concat user-emacs-directory (convert-standard-filename "undo")))
  :config (global undo-tree-mode)
  :bind ("s-/" . undo-tree-visualize))

;; Convenience functions for checking whether we're in windows or not
(defun not-windows ()
  "Check if OS is not windows, return t if not."
  (not (string-equal system-type "windows-nt")))

(defun is-windows ()
  "Check if OS is windows, return t if it is."
  (string-equal system-type "windows-nt"))

(defun is-linux ()
  "Check if OS is linux, return t if it is."
  (string-equal system-type "gnu/linux"))

(defun is-wsl ()
  "Check if OS is a WSL version of Linux, return t if it is."
  (let ((wsl
        (with-temp-buffer
          (insert-file-contents "/proc/version")
          (re-search-forward "Microsoft" nil t))))
    (if wsl
        t
      nil)))

(defvar buffer-local-ignores
  '(
    buffer-undo-list
    company-last-metadata
    font-lock-keywords
    imenu-generic-expression
    lsp--buffer-workspaces
    lsp--document-symbols
    lsp-headerline--path-up-to-project-string
    lsp-headerline--string
    lsp-lens--refresh-timer
    lsp-ui-doc--timer
    lsp-ui-doc--timer-mouse-movement
    lsp-ui-sideline--timer
    mark-ring
    rm--help-echo
    sml/buffer-identification
    sml/buffer-identification-filling
    spinner-current
    vc-mode
    ))

;; Reveal all the buffer local variables
(defun buffer-locals (&optional buffer-name)
  "Will reveal the BUFFER-NAME local variables like Aladdin in a Whole New World."
  (interactive "b")
  (let* ((buffer (get-buffer buffer-name))
         (alist-o-vars (buffer-local-variables buffer))
         (excluded-buffers (lambda (elem)
                             (memq (car elem) buffer-local-ignores))))
    (with-help-window (format "*BFL %s" buffer-name)
      (pp
       (-remove excluded-buffers alist-o-vars)))))

;; FOOTER
