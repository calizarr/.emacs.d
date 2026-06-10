;; -*- lexical-binding: t; -*-

;;; codex.el --- use-package config for benthamite/codex (OpenAI Codex CLI)
;;
;; https://github.com/benthamite/codex
;;
;; codex.el embeds the OpenAI Codex CLI TUI directly into an eat buffer,
;; modelled closely after claude-code.el. It supports session management,
;; region/buffer sending, error-at-point fixing, slash commands, live model
;; and sandbox switching via transient infixes, and desktop notifications.
;;
;; Prerequisites:
;;   - Emacs 28.1+ (29+ recommended for :vc install)
;;   - eat >= 0.9.4 (already in your config)
;;   - inheritenv >= 0.2 (already pulled in for claude-code.el)
;;   - OpenAI Codex CLI: npm install -g @openai/codex
;;     (or via the official installer if one ships)
;;   - OPENAI_API_KEY set in your environment
;;
;; Note on C-c x: verify it's free in your config.
;; Your consult.el uses C-c h/k/m/i; C-c x is unoccupied.
;; (global-key-binding (kbd "C-c x")) => nil means it's free.


(use-package codex
  :vc (:url "https://github.com/benthamite/codex" :rev :newest)
  ;; Or via elpaca:
  ;; :ensure (:host github :repo "benthamite/codex")
  ;; Or via straight:
  ;; :straight (:host github :repo "benthamite/codex")

  :demand t  ;; needed with use-package-always-defer t

  :init
  ;; Terminal backend. eat is the default and matches your config.
  ;; Switch to 'vterm if you prefer (requires vterm installed).
  (setq codex-terminal-backend 'eat)

  ;; Disable alt-screen TUI. This is the recommended setting for Emacs
  ;; terminal buffers — avoids stale screen state after interrupts and redraws.
  ;; Set to t only if you specifically want the full TUI experience.
  (setq codex-use-alt-screen nil)

  ;; Keep the Codex window visible when running delete-other-windows.
  (setq codex-no-delete-other-windows t)

  ;; Auto-focus Codex window when toggling it open.
  (setq codex-toggle-auto-select t)

  ;; Confirm before killing a Codex instance.
  (setq codex-confirm-kill t)

  ;; RET sends, S-RET inserts a newline. Matches claude-code.el default.
  ;; Options: 'newline-on-shift-return 'newline-on-alt-return
  ;;          'shift-return-to-send   'super-return-to-send
  (setq codex-newline-keybinding-style 'newline-on-shift-return)

  ;; Notify when Codex finishes and awaits input.
  (setq codex-enable-notifications t)

  ;; Remap hardcoded RGB backgrounds from Codex's TUI to respect your
  ;; Emacs theme. See the long comment in codex.el for background on why
  ;; this is necessary. 1.0 strips any explicit background not matching
  ;; your Emacs default — most aggressive, cleanest result.
  (setq codex-remap-light-backgrounds t
        codex-background-contrast-threshold 1.0
        codex-minimum-contrast-ratio 3.0)

  ;; Style autosuggestion placeholder text with shadow face.
  (setq codex-enable-prompt-autosuggestions t)

  ;; Unlimited eat scrollback for long Codex sessions.
  (setq codex-eat-scrollback-size nil)

  ;; Suppress eat's blinking cursor timer (reduces frame redraws on macOS
  ;; and is generally less distracting).
  (setq codex-eat-disable-cursor-blink t)

  ;; Side window placement — mirror claude-code-packages.el layout.
  (add-to-list 'display-buffer-alist
               '("^\\*codex"
                 (display-buffer-in-side-window)
                 (side . right)
                 (window-width . 90)))

  ;; Auto-revert buffers after Codex edits files on disk.
  (global-auto-revert-mode 1)
  (setq auto-revert-use-notify nil)

  :config
  ;; Enable the global minor mode. This writes/repairs ~/.codex/config.toml
  ;; and ~/.codex/hooks.json so Codex CLI hooks reach Emacs via emacsclient.
  ;; Existing user hooks are preserved.
  (codex-mode 1)

  ;; ---------- Model defaults ----------
  ;; codex-model nil means "use CLI default" (currently codex-mini).
  ;; Set to a string to pin a model, or leave nil and switch live via
  ;; the transient infix C-c x m → g m.
  ;; (setq codex-model "gpt-5.4")          ; full model ID
  ;; (setq codex-model "codex-mini")        ; alias

  ;; ---------- Sandbox and approval defaults ----------
  ;; nil defers to the CLI default (workspace-write for most operations).
  ;; Override here or switch live via the transient.
  (setq codex-sandbox-mode nil)
  (setq codex-approval-policy nil)

  ;; ---------- Reasoning effort ----------
  ;; nil = CLI default. Other values: "low" "medium" "high".
  ;; Switch live via transient infix g e.
  (setq codex-reasoning-effort nil)

  ;; ---------- Model switching helpers ----------
  ;; Call M-x codex/use-model or bind to keys. Takes effect on next
  ;; session start — use the transient infix (g m) to change mid-session.

  (defun codex/set-model (model)
    "Set codex-model to MODEL and report the change."
    (interactive
     (list (completing-read
            "Codex model: "
            '("codex-mini" "gpt-5.4" "o3" "o4-mini")
            nil nil nil nil "codex-mini")))
    (setq codex-model (if (string-empty-p model) nil model))
    (message "Codex model set to: %s (use transient g m to change mid-session)"
             (or codex-model "CLI default")))

  (defun codex/use-default     () (interactive) (setq codex-model nil)        (message "Codex model: CLI default"))
  (defun codex/use-codex-mini  () (interactive) (setq codex-model "codex-mini") (message "Codex model: codex-mini"))
  (defun codex/use-o3          () (interactive) (setq codex-model "o3")        (message "Codex model: o3"))
  (defun codex/use-o4-mini     () (interactive) (setq codex-model "o4-mini")   (message "Codex model: o4-mini"))

  ;; ---------- Sandbox switching helpers ----------
  (defun codex/sandbox-default         () (interactive) (setq codex-sandbox-mode nil)                (message "Codex sandbox: CLI default"))
  (defun codex/sandbox-read-only       () (interactive) (setq codex-sandbox-mode 'read-only)         (message "Codex sandbox: read-only"))
  (defun codex/sandbox-workspace-write () (interactive) (setq codex-sandbox-mode 'workspace-write)   (message "Codex sandbox: workspace-write"))

  ;; ---------- Auto-start hook (commented out) ----------
  ;; Uncomment to start a Codex session automatically when opening a file
  ;; in a project. Per-project isolation via project.el applies here too.
  ;; (add-hook 'project-find-file-hook #'codex)

  :bind-keymap
  ;; All Codex commands under C-c x.
  ;; C-c x c  start | C-c x s  send command | C-c x r  send region
  ;; C-c x e  fix error at point | C-c x t  toggle window
  ;; C-c x m  transient menu | C-c x /  slash commands
  ("C-c x" . codex-command-map))
