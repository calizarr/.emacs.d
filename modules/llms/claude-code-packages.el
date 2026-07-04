;; -*- lexical-binding: t; -*-
;;; claude-code-packages.el --- use-package config for Claude Code Emacs integrations
;;
;; Three packages are configured here. Only one should be active at a time —
;; comment out the others while experimenting. Each is self-contained.
;;
;; Prerequisites (all three packages share these):
;;   - Emacs 29+ (30+ recommended for built-in :vc support)
;;   - Claude Code CLI installed: curl -fsSL https://claude.ai/install.sh | bash
;;   - A terminal backend: eat (pure elisp, easiest) or vterm (faster, needs C compile)
;;
;; Terminal backend — install whichever you prefer (eat is the easier starting point):

(use-package eat
  :ensure t
  ;; Required for NonGNU ELPA if not using :vc install:
  ;; (add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
  )

;; Or: vterm (comment out eat above and uncomment this)
;; (use-package vterm :ensure t)

;; Required by claude-code.el (stevemolitor):
(use-package inheritenv
  :vc (:url "https://github.com/purcell/inheritenv" :rev :newest))


;;; ============================================================
;;; OPTION 1: claude-code.el (stevemolitor)
;;; https://github.com/stevemolitor/claude-code.el
;;;
;;; The most mature and well-documented of the three. Focuses on
;;; a clean terminal wrapper with multi-instance support, flycheck/
;;; flymake error fixing, image paste, and desktop notifications.
;;; Pair with Monet (see below) for full IDE/LSP integration.
;;; ============================================================

;; (use-package claude-code
;;   :ensure t
;;   :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)

;;   :init
;;   ;; Terminal backend: 'eat (default), 'vterm, or 'ghostel
;;   (setq claude-code-terminal-backend 'eat)

;;   ;; Keep Claude window visible when running delete-other-windows
;;   (setq claude-code-no-delete-other-windows t)

;;   ;; Auto-focus Claude window when toggling it open
;;   (setq claude-code-toggle-auto-select t)

;;   ;; Confirm before killing a Claude session
;;   (setq claude-code-confirm-kill t)

;;   ;; How RET/S-RET behave inside the Claude buffer.
;;   ;; Options: 'newline-on-shift-return (default), 'newline-on-alt-return,
;;   ;;          'shift-return-to-send, 'super-return-to-send
;;   (setq claude-code-newline-keybinding-style 'newline-on-shift-return)

;;   ;; Notify (minibuffer + modeline pulse) when Claude finishes processing
;;   (setq claude-code-enable-notifications t)

;;   ;; Display Claude in a side window on the right at 90 cols.
;;   ;; Remove or adjust to taste.
;;   (add-to-list 'display-buffer-alist
;;                '("^\\*claude"
;;                  (display-buffer-in-side-window)
;;                  (side . right)
;;                  (window-width . 90)))

;;   ;; Auto-revert buffers after Claude edits files on disk.
;;   ;; Claude writes to disk; Emacs won't know without this.
;;   (global-auto-revert-mode 1)
;;   (setq auto-revert-use-notify nil)  ; use polling if notify is unreliable

;;   :config
;;   ;; Enable the global minor mode (sets up keymaps, hooks, etc.)
;;   (claude-code-mode)

;;   ;; Reduce eat latency slightly to cut down on flickering in the terminal buffer
;;   (add-hook 'claude-code-start-hook
;;             (lambda ()
;;               (when (eq claude-code-terminal-backend 'eat)
;;                 (setq-local eat-minimum-latency 0.033
;;                             eat-maximum-latency 0.1))))

;;   ;; Auto-start Claude when switching into a project.
;;   ;; Uncomment to experiment — sessions are per-project so this is low-noise,
;;   ;; but it will spin up a Claude process for every project you open.
;;   ;; (add-hook 'project-find-file-hook #'claude-code)

;;   :bind-keymap
;;   ;; All Claude commands live under this prefix.
;;   ;; C-c c c  start | C-c c s  send command | C-c c e  fix error at point
;;   ;; C-c c t  toggle window | C-c c b  switch to buffer | C-c c k  kill
;;   ("C-c c" . claude-code-command-map)

;;   :bind
;;   ;; Optional repeat-map: after C-c c M, pressing M again cycles modes
;;   (:repeat-map my-claude-code-repeat-map
;;                ("M" . claude-code-cycle-mode)))


;; ;; Monet — IDE bridge for claude-code.el (optional but recommended for LSP use)
;; ;; Sends your current selection and Flymake/Flycheck diagnostics to Claude,
;; ;; and shows diffs inside Emacs before they are applied.
;; ;; https://github.com/stevemolitor/monet
;; ;;
;; ;; Note: the repo contains large GIFs so the initial clone is slow.
;; (use-package monet
;;   :vc (:url "https://github.com/stevemolitor/monet" :rev :newest)
;;   :after claude-code
;;   :config
;;   ;; Wire Monet into claude-code.el: starts a WebSocket server whenever
;;   ;; Claude launches so it can receive IDE events (selection, diagnostics, diffs).
;;   (add-hook 'claude-code-process-environment-functions
;;             #'monet-start-server-function)
;;   (monet-mode 1))


;;; ============================================================
;;; OPTION 2: claude-code-ide.el (manzaltu)
;;; https://github.com/manzaltu/claude-code-ide.el
;;;
;;; Deeper MCP integration than claude-code.el: bidirectional bridge
;;; so Claude can call back into Emacs to query LSP (via xref), tree-sitter,
;;; imenu, project.el, and diagnostics. Ediff-based diff review.
;;; Slightly newer/more experimental than option 1.
;;; ============================================================

(use-package claude-code-ide
  :demand t
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)

  :init
  ;; Terminal backend: 'vterm (default), 'eat, or 'ghostel
  (setq claude-code-ide-terminal-backend 'eat)

  ;; Side window placement. Options: 'right (default), 'left, 'top, 'bottom
  (setq claude-code-ide-window-side 'right)
  (setq claude-code-ide-window-width 100)

  ;; Focus the Claude window when it opens
  (setq claude-code-ide-focus-on-open t)

  ;; Show ediff diff view when Claude proposes changes (recommended)
  (setq claude-code-ide-use-ide-diff t)

  ;; Keep Claude window visible alongside ediff
  (setq claude-code-ide-show-claude-window-in-ediff t)

  ;; Diagnostics backend: 'auto detects flycheck or flymake automatically
  (setq claude-code-ide-diagnostics-backend 'flycheck)
  ;; (setq claude-code-ide-diagnostics-backend 'auto)

  ;; Allow Claude to evaluate Elisp in your running Emacs session via MCP.
  ;; Set nil if you'd rather keep Claude out of live Emacs evaluation.
  (setq claude-code-ide-enable-execute-code t)

  ;; Pass extra CLI flags, e.g. to pin a model:
  ;; (setq claude-code-ide-cli-extra-flags "--model opus")

  :config
  ;; Unlimited eat scrollback so Claude's normal-screen output (startup
  ;; banners, errors, anything printed outside the TUI's alternate screen)
  ;; stays scrollable instead of being truncated at eat's default cap.
  ;; NOTE: the TUI itself renders in the alternate screen buffer, which is
  ;; never added to scrollback by design — this maximizes what *is* capturable.
  (with-eval-after-load 'eat
    (setq eat-term-scrollback-size nil))

  ;; Enable the built-in Emacs MCP tools: xref-find-references,
  ;; xref-find-apropos, treesit-info, imenu-list-symbols, project-info.
  ;; This is what gives Claude access to your LSP/xref data.
  (claude-code-ide-emacs-tools-setup)

  ;; Auto-start Claude when switching into a project.
  ;; Each project gets its own session, so this is fairly low-noise.
  (add-hook 'project-find-file-hook #'claude-code-ide)

  ;; Keep Claude side window clamped to configured width after frame/font resizes.
  ;; Side windows expand proportionally when the frame changes; this corrects them.
  (defun my/claude-clamp-window-width ()
    (dolist (win (window-list))
      (when (and (window-live-p win)
                 (string-prefix-p "*claude-code[" (buffer-name (window-buffer win))))
        (let ((delta (- claude-code-ide-window-width (window-body-width win))))
          (unless (< (abs delta) 2)
            (ignore-errors (window-resize win delta t)))))))
  (add-hook 'window-configuration-change-hook #'my/claude-clamp-window-width)

  ;; After a frame font change, re-sync the terminal process dimensions.
  ;; The eat/vterm process must be told its new column count or display garbles.
  (add-hook 'after-setting-font-hook
            (lambda ()
              (run-with-timer 0.2 nil
                              (lambda ()
                                (dolist (buf (buffer-list))
                                  (when (string-prefix-p "*claude-code[" (buffer-name buf))
                                    (dolist (win (get-buffer-window-list buf nil t))
                                      (claude-code-ide--sync-terminal-dimensions buf win))))))))

  ;; text-scale-increase/decrease in a terminal buffer changes visual font size
  ;; without updating the process column count, causing garbled line wrapping.
  ;; Disable those keybindings inside Claude eat sessions.
  (add-hook 'eat-mode-hook
            (lambda ()
              (when (string-prefix-p "*claude-code[" (buffer-name))
                (local-set-key (kbd "S-s-=") #'ignore)
                (local-set-key (kbd "s--") #'ignore)
                (local-set-key (kbd "s-0") #'ignore))))

  :bind
  ("C-c C-'" . claude-code-ide-menu))   ; transient menu with all commands


;;; ============================================================
;;; OPTION 3: claude-code-emacs (yuya373)
;;; https://github.com/yuya373/claude-code-emacs
;;;
;;; MCP-first design: per-project sessions via WebSocket, smart @-file
;;; completion in prompts, transient menus, and custom slash commands
;;; stored as Markdown files in .claude/commands/*.md.
;;; Requires the companion MCP server npm package.
;;; ============================================================

;; Prerequisites for option 3:
;;   npm install -g claude-code-mcp-server
;;   claude mcp add-json emacs '{"type":"stdio","command":"claude-code-mcp"}'

;; (use-package claude-code
;;   ;; Note: this is yuya373's package, distinct from stevemolitor's above.
;;   ;; If using both at once you'd need to manage load-path manually;
;;   ;; enable only one at a time.
;;   :load-path "~/.emacs.d/site-lisp/claude-code-emacs"  ; cloned manually
;;
;;   :init
;;   ;; Path to the Claude CLI binary (default "claude" assumes it's on PATH)
;;   ;; (setq claude-code-claude-command "claude")
;;
;;   ;; Auto-start Claude when switching into a project via project.el
;;   ;; (add-hook 'project-find-file-hook #'claude-code-run)
;;
;;   :config
;;   (global-set-key (kbd "C-c c") 'claude-code-transient))


;;; claude-code-packages.el ends here
