;; -*- lexical-binding: t; -*-

;;; ai-code-interface.el --- use-package config for ai-code-interface.el
;;
;; https://github.com/tninja/ai-code-interface.el
;;
;; ai-code-interface provides a single transient menu (C-c a) that works
;; identically across multiple AI CLI backends. You switch the backend
;; once (C-c a s) and all context-gathering, TDD, refactor, and review
;; commands keep working without relearning keybindings.
;;
;; It ships with adapters for: claude-code, claude-code-ide, claude-code-el,
;; codex, gemini, github-copilot-cli, opencode, aider, grok, kilo, and more.
;;
;; Prerequisites:
;;   - Emacs 29.1+
;;   - magit (hard dependency in the package header)
;;   - eat or vterm terminal backend
;;   - Claude Code CLI: curl -fsSL https://claude.ai/install.sh | bash
;;   - OpenAI Codex CLI: npm install -g @openai/codex  (for codex backend)
;;     OPENAI_API_KEY must be set in your environment for the codex backend.
;;
;; Note on C-c a: your consult.el uses C-c h, C-c k, C-c m, C-c i under
;; C-c, but C-c a is free. Verify with: (global-key-binding (kbd "C-c a"))
;;
;; Note on codex backend vs benthamite/codex.el:
;;   ai-code-interface's built-in 'codex adapter calls the Codex CLI
;;   directly as a terminal session. benthamite/codex.el (configured in
;;   codex.el) is a richer standalone package that adds session forking,
;;   slash command menus, live transient infixes for model/sandbox/approval,
;;   and theme-aware background remapping. The two are complementary:
;;   use ai-code-interface's 'codex adapter for backend portability, and
;;   benthamite/codex.el's own keybindings (C-c x) for Codex-specific
;;   features that have no equivalent in ai-code-interface.


(use-package ai-code
  :vc (:url "https://github.com/tninja/ai-code-interface.el" :rev :newest)
  ;; Or via straight:
  ;; :straight (:host github :repo "tninja/ai-code-interface.el")
  ;; Or via MELPA if available:
  ;; :ensure t

  :demand t  ;; needed since you have use-package-always-defer t globally

  :init
  ;; Terminal backend. eat is already in your config so use that;
  ;; switch to 'vterm or 'ghostel if you prefer.
  (setq ai-code-backends-infra-terminal-backend 'eat)

  ;; Transient menu layout. 'default is the wide multi-column layout,
  ;; 'two-columns is narrower — useful on smaller frames.
  (setq ai-code-menu-layout 'default)

  ;; Auto-revert interval in seconds. Shared with global-auto-revert-mode.
  (setq auto-revert-interval 1)

  :config
  ;; ---------- Backend selection ----------
  ;; Default to claude-code. Switch interactively at any time with C-c a s.
  ;;
  ;; Available backends (all supported by your installed CLIs):
  ;;   'claude-code      — Claude CLI (your primary, already installed)
  ;;   'claude-code-ide  — Delegates to claude-code-ide.el (MCP/LSP bridge)
  ;;   'codex            — OpenAI Codex CLI (ai-code's built-in adapter)
  ;;   'gemini           — Gemini CLI
  ;;   'aider            — Aider (multi-model, including Claude)
  ;;   'opencode         — Opencode (open-source Claude Code alternative)
  (ai-code-set-backend 'claude-code-ide)

  ;; ---------- Claude model switching ----------
  ;; ai-code passes --model flags through to the Claude CLI.
  ;; Takes effect on next session start; use the CLI's /model slash command
  ;; to switch mid-session.

  (defun ai-code/set-claude-model (model)
    "Set the Claude Code --model flag.
MODEL is a string like \"opus\", \"sonnet\", or a full model ID."
    (interactive
     (list (completing-read
            "Claude model: "
            '("opus" "sonnet" "haiku"
              "claude-opus-4-6" "claude-sonnet-4-6" "claude-haiku-4-5")
            nil nil nil nil "sonnet")))
    (setq ai-code-claude-code-extra-args (list "--model" model))
    (message "Claude model set to: %s (takes effect on next session start)" model))

  (defun ai-code/use-opus   () (interactive) (ai-code/set-claude-model "opus"))
  (defun ai-code/use-sonnet () (interactive) (ai-code/set-claude-model "sonnet"))
  (defun ai-code/use-haiku  () (interactive) (ai-code/set-claude-model "haiku"))

  ;; ---------- Codex backend configuration ----------
  ;; When you switch to the 'codex backend (C-c a s → codex), ai-code
  ;; calls the Codex CLI with any args set in ai-code-codex-extra-args.
  ;; These mirror the flags codex.el exposes via its transient infixes.

  (defun ai-code/set-codex-model (model)
    "Set the Codex --model flag for the ai-code 'codex backend.
MODEL is a string like \"codex-mini\", \"o3\", or \"o4-mini\"."
    (interactive
     (list (completing-read
            "Codex model: "
            '("codex-mini" "o3" "o4-mini" "gpt-5.4")
            nil nil nil nil "codex-mini")))
    (setq ai-code-codex-extra-args
          (if (string-empty-p model) nil (list "--model" model)))
    (message "Codex model set to: %s (takes effect on next session start)"
             (or model "CLI default")))

  (defun ai-code/codex-use-default    () (interactive) (setq ai-code-codex-extra-args nil)                     (message "Codex: CLI default model"))
  (defun ai-code/codex-use-codex-mini () (interactive) (setq ai-code-codex-extra-args '("--model" "codex-mini")) (message "Codex: codex-mini"))
  (defun ai-code/codex-use-o3         () (interactive) (setq ai-code-codex-extra-args '("--model" "o3"))         (message "Codex: o3"))
  (defun ai-code/codex-use-o4-mini    () (interactive) (setq ai-code-codex-extra-args '("--model" "o4-mini"))    (message "Codex: o4-mini"))

  ;; ---------- Backend-aware model switcher ----------
  ;; Single entry point: dispatches to the right set of model helpers
  ;; based on which backend is currently active. Bind to a key for
  ;; quick access without opening the full transient.

  (defun ai-code/switch-model ()
    "Switch model for the currently active ai-code backend."
    (interactive)
    (pcase (ai-code-current-backend-label)
      ((or "claude-code" "claude-code-ide" "claude-code-el")
       (call-interactively #'ai-code/set-claude-model))
      ("codex"
       (call-interactively #'ai-code/set-codex-model))
      (_
       (message "No model switcher defined for backend: %s"
                (ai-code-current-backend-label)))))

  ;; ---------- Prompt suffix ----------
  ;; Appended to every prompt when ai-code-use-prompt-suffix is t.
  ;; Toggle live with ^ in the transient menu.
  (setq ai-code-prompt-suffix nil)

  ;; ---------- TDD / test loop ----------
  ;; 'ask-me  — prompts whether to run tests after each code change
  ;; 'auto    — always runs tests automatically
  ;; nil      — never runs tests
  (setq ai-code-auto-test-type 'ask-me)

  ;; ---------- Quick prompts (C-c a Q) ----------
  ;; Pre-defined prompts for the completing-read picker.
  ;; Having both Claude and Codex in mind; these are backend-agnostic.
  (setq ai-code-quick-prompts
        '("Explain what this function does and how it fits into the project."
          "Are there any edge cases or error conditions not handled here?"
          "Suggest a more idiomatic rewrite of this code."
          "Write docstrings for all public functions in this buffer."
          "Add unit tests for the selected code."
          "Identify any performance concerns in this buffer."
          "What does this file do? Give a one-paragraph summary."
          "What are the dependencies between the functions in this buffer?"
          "Review this code for potential security issues."))

  ;; ---------- Discussion follow-up ----------
  ;; When t, discussion prompts auto-append numbered next-step suggestions.
  ;; Toggle live with F in the transient menu.
  (setq ai-code-discussion-auto-follow-up-enabled t)

  ;; ---------- auto-revert ----------
  (global-auto-revert-mode 1)

  ;; ---------- Project auto-start (commented out) ----------
  ;; Uncomment to auto-start the current backend when opening a project file.
  ;; Each project gets its own session.
  ;; (add-hook 'project-find-file-hook #'ai-code-cli-start)

  ;; ---------- Global keybinding ----------
  (global-set-key (kbd "C-c a") #'ai-code-menu)

  ;; Bind the backend-aware model switcher to a convenient key.
  ;; C-c a is the transient hub; this is a direct shortcut outside it.
  (global-set-key (kbd "C-c M-a") #'ai-code/switch-model)

  ;; ---------- Optional: per-mode backend switching ----------
  ;; Switch to Codex for Go/Python if you prefer its style there,
  ;; and stay on Claude for Scala/Terraform.
  ;; (add-hook 'go-mode-hook     (lambda () (ai-code-set-backend 'codex)))
  ;; (add-hook 'python-mode-hook (lambda () (ai-code-set-backend 'codex)))
  ;; (add-hook 'scala-mode-hook  (lambda () (ai-code-set-backend 'claude-code)))

  ;; ---------- Optional: per-mode Claude model switching ----------
  ;; Use Opus for Scala (heavier reasoning), Sonnet elsewhere.
  ;; (add-hook 'scala-mode-hook #'ai-code/use-opus)
  ;; (add-hook 'go-mode-hook    #'ai-code/use-opus)

  ;; ---------- Optional: Evil integration ----------
  ;; (with-eval-after-load 'evil
  ;;   (ai-code-backends-infra-evil-setup))
  )


;;; Three-package interaction reference
;;; ------------------------------------
;;;
;;;  Package           Prefix    Best for
;;;  ─────────────────────────────────────────────────────────────────────
;;;  claude-code-ide   C-c C-'   LSP/xref MCP bridge; Claude sees your
;;;                              diagnostics, references, tree-sitter AST.
;;;                              Use when Claude needs to navigate your
;;;                              Emacs state actively.
;;;
;;;  ai-code-interface C-c a     Uniform workflow across backends: TDD loop,
;;;                              refactor navigator, PR review, checkpoint,
;;;                              architecture derivation. Use when you want
;;;                              the same commands regardless of which CLI
;;;                              you are running underneath.
;;;                              Switch backend:   C-c a s
;;;                              Switch model:     C-c M-a (or C-c a s → model)
;;;
;;;  codex.el          C-c x     Codex-specific richness: session forking,
;;;                              slash command menu (C-c x /), live transient
;;;                              infixes for model/sandbox/approval/profile,
;;;                              theme-aware background remapping. Use when
;;;                              you want the full Codex TUI experience.
;;;
;;;  Typical workflow:
;;;    - Open a project and invoke claude-code-ide for LSP-aware Claude work.
;;;    - Use C-c a for TDD, review, or checkpoint commands regardless of
;;;      which AI is active.
;;;    - Switch to Codex (C-c a s → codex or C-c x c) when you want to
;;;      compare responses or use a different model for a specific task.
;;;    - Use C-c x / for Codex slash commands (/review, /diff, /compact).


;;; ai-code-interface.el ends here
