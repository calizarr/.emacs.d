;;; aider.el --- use-package config for aider.el (tninja/aider.el)
;;
;; https://github.com/tninja/aider.el
;;
;; Aider is a vendor-agnostic agentic coding CLI. It works with any
;; OpenAI-compatible API endpoint, making it the natural home for:
;;   - Local LLMs via Ollama (privacy, no API billing, offline use)
;;   - Architect/editor split: one model reasons, another edits
;;   - Mixing local models with cloud APIs per-task
;;
;; IMPORTANT: API KEY POLICY (as of February 2026)
;;   Anthropic has banned using Claude.ai subscription OAuth tokens in
;;   third-party tools. Your Claude Code login credentials cannot be
;;   used in Aider. To use Claude models in Aider you need a separate
;;   ANTHROPIC_API_KEY from console.anthropic.com (pay-as-you-go).
;;   The same applies to OpenAI — a separate OPENAI_API_KEY is required.
;;
;;   For local Ollama models: no API key needed at all. This is the
;;   recommended starting point for experimenting with Aider without
;;   any billing concerns.
;;
;; Prerequisites:
;;   pip install aider-chat          # Aider CLI
;;   curl -fsSL https://ollama.ai/install.sh | sh   # Ollama (for local LLMs)
;;
;; Recommended Ollama models for the architect/editor split:
;;   Architect (reasoning):
;;     ollama pull qwen2.5-coder:32b     # 20GB, excellent for code reasoning
;;     ollama pull deepseek-coder-v2:16b # 10GB, strong code understanding
;;     ollama pull llama3.3:70b          # 40GB, best quality if you have VRAM
;;   Editor (fast mechanical edits):
;;     ollama pull qwen2.5-coder:14b     # 9GB, fast and accurate for edits
;;     ollama pull qwen2.5-coder:7b      # 5GB, very fast, good for simple edits
;;     ollama pull deepseek-coder:6.7b   # 4GB, lightweight option
;;
;; Note on C-c a: already used by ai-code-interface.el.
;; aider.el defaults to C-c a as well — you need to change one.
;; This config uses C-c A (capital A) for aider to avoid the clash.


(use-package aider
  :vc (:url "https://github.com/tninja/aider.el" :rev :newest)
  ;; Or via straight:
  ;; :straight (:host github :repo "tninja/aider.el"
  ;;            :files ("aider.el" "aider-core.el" "aider-file.el"
  ;;                    "aider-code-change.el" "aider-discussion.el"
  ;;                    "aider-prompt-mode.el"))

  :demand t

  :init
  ;; ---------- Default model ----------
  ;; Start with a local Ollama model so no API key is needed.
  ;; Switch to a cloud model by calling one of the helpers below,
  ;; or use C-u before M-x aider to override args interactively.
  ;;
  ;; Local options (no API key, no billing):
  (setq aider-args '("--model" "ollama/qwen2.5-coder:32b"
                     "--no-auto-commits"))   ; don't auto-commit, review first

  ;; Cloud options (require separate API keys — see policy note above):
  ;;
  ;; Claude via direct API key (NOT your Claude Code subscription):
  ;; (setq aider-args '("--model" "claude-sonnet-4-6"
  ;;                    "--no-auto-commits"))
  ;;
  ;; OpenAI via direct API key:
  ;; (setq aider-args '("--model" "gpt-5.4"
  ;;                    "--no-auto-commits"))
  ;;
  ;; DeepSeek (cheap, strong for code):
  ;; (setq aider-args '("--model" "deepseek/deepseek-coder"
  ;;                    "--no-auto-commits"))

  :config
  ;; ---------- API keys (only needed for cloud models) ----------
  ;; Set these only if using cloud models. Do NOT reuse your Claude Code
  ;; OAuth token here — that violates Anthropic's ToS as of Feb 2026.
  ;; Better practice: set these in your shell environment (~/.zshenv or
  ;; ~/.bashrc) rather than hardcoding them here.
  ;;
  ;; (setenv "ANTHROPIC_API_KEY" "sk-ant-api03-...")   ; from console.anthropic.com
  ;; (setenv "OPENAI_API_KEY"    "sk-proj-...")        ; from platform.openai.com
  ;; (setenv "DEEPSEEK_API_KEY"  "sk-...")             ; from platform.deepseek.com

  ;; ---------- Auto-revert ----------
  ;; Aider edits files on disk; Emacs needs to pick up those changes.
  (global-auto-revert-mode 1)
  (auto-revert-mode 1)

  ;; ---------- Magit integration ----------
  ;; Adds Aider commands to the Magit transient menu.
  ;; Remove if you don't use Magit (though your config likely does).
  (aider-magit-setup-transients)

  ;; ---------- Model preset helpers ----------
  ;; Call these interactively (M-x) or bind them. Each takes effect on
  ;; the next M-x aider invocation, not mid-session. To switch mid-session
  ;; use the /model slash command inside the Aider buffer.

  ;; --- Local Ollama presets (no API key required) ---

  (defun aider/local-architect-32b ()
    "Use qwen2.5-coder:32b locally — best quality architect model."
    (interactive)
    (setq aider-args '("--model" "ollama/qwen2.5-coder:32b" "--no-auto-commits"))
    (message "Aider: local qwen2.5-coder:32b (architect)"))

  (defun aider/local-fast-14b ()
    "Use qwen2.5-coder:14b locally — fast editor model."
    (interactive)
    (setq aider-args '("--model" "ollama/qwen2.5-coder:14b" "--no-auto-commits"))
    (message "Aider: local qwen2.5-coder:14b (fast editor)"))

  (defun aider/local-deepseek-16b ()
    "Use deepseek-coder-v2:16b locally — strong on multilingual code."
    (interactive)
    (setq aider-args '("--model" "ollama/deepseek-coder-v2:16b" "--no-auto-commits"))
    (message "Aider: local deepseek-coder-v2:16b"))

  ;; --- Architect/editor split presets ---
  ;; The architect model reasons about what to change; the editor model
  ;; applies the actual file edits. Use a stronger model for architect
  ;; and a faster/cheaper one for editor.
  ;;
  ;; All-local split (no API key, no billing):
  (defun aider/local-split-32b-7b ()
    "Architect/editor split: qwen2.5-coder:32b reasons, :7b edits."
    (interactive)
    (setq aider-args '("--model"        "ollama/qwen2.5-coder:32b"
                       "--editor-model" "ollama/qwen2.5-coder:7b"
                       "--no-auto-commits"))
    (message "Aider: local split — 32b architect / 7b editor"))

  (defun aider/local-split-deepseek-qwen ()
    "Architect/editor split: deepseek-coder-v2:16b reasons, qwen2.5-coder:7b edits."
    (interactive)
    (setq aider-args '("--model"        "ollama/deepseek-coder-v2:16b"
                       "--editor-model" "ollama/qwen2.5-coder:7b"
                       "--no-auto-commits"))
    (message "Aider: local split — deepseek-coder-v2:16b architect / qwen:7b editor"))

  ;; Cloud + local hybrid split (requires API key for the architect model):
  ;; Use cloud intelligence for reasoning, local speed for edits.
  ;;
  ;; (defun aider/hybrid-claude-local ()
  ;;   "Architect/editor split: Claude Sonnet reasons, local qwen:14b edits."
  ;;   (interactive)
  ;;   (setq aider-args '("--model"        "claude-sonnet-4-6"
  ;;                      "--editor-model" "ollama/qwen2.5-coder:14b"
  ;;                      "--no-auto-commits"))
  ;;   (message "Aider: hybrid — Claude Sonnet architect / local qwen:14b editor"))
  ;;
  ;; (defun aider/hybrid-deepseek-local ()
  ;;   "Architect/editor split: DeepSeek reasons, local qwen:7b edits."
  ;;   (interactive)
  ;;   (setq aider-args '("--model"        "deepseek/deepseek-coder"
  ;;                      "--editor-model" "ollama/qwen2.5-coder:7b"
  ;;                      "--no-auto-commits"))
  ;;   (message "Aider: hybrid — DeepSeek architect / local qwen:7b editor"))

  ;; ---------- Per-language model suggestions ----------
  ;; Based on benchmark data and developer reports. Uncomment the hooks
  ;; for the languages where you want non-default models.
  ;; Note: these set aider-args globally, not per-buffer, so they affect
  ;; the *next* Aider session started, not any running one.
  ;;
  ;; Scala: stronger reasoning model worthwhile given type system complexity
  ;; (add-hook 'scala-mode-hook #'aider/local-architect-32b)
  ;;
  ;; Rust: same reasoning argument; 32b handles borrow checker concepts well
  ;; (add-hook 'rust-mode-hook #'aider/local-architect-32b)
  ;;
  ;; Go/Bash: fast iteration more important, lighter model is fine
  ;; (add-hook 'go-mode-hook #'aider/local-fast-14b)
  ;; (add-hook 'sh-mode-hook #'aider/local-fast-14b)

  ;; ---------- Project-local model settings ----------
  ;; Aider reads .aider.model.settings.yml from the project root.
  ;; This is where you set num_ctx (critical for local models) and
  ;; edit_format. The snippet function below creates one interactively.

  (defun aider/create-m4-model-settings ()
    "Create ~/.aider.model.settings.yml with settings tuned for M4 Max 48GB.
Creates a global file applicable to all projects. A project-local
.aider.model.settings.yml in the repo root will take precedence over this."
    (interactive)
    (let ((path (expand-file-name "~/.aider.model.settings.yml")))
      (if (file-exists-p path)
          (progn (find-file path)
                 (message "~/.aider.model.settings.yml already exists — opened for editing"))
        (find-file path)
        (insert "\
# ~/.aider.model.settings.yml — global model settings for M4 Max 48GB
# https://aider.chat/docs/config/model-settings.html
#
# Precedence: project-local .aider.model.settings.yml > this file.
# Add a project-local file to override num_ctx on large repos where
# you want to conserve KV cache memory.
#
# edit_format:
#   diff  — model outputs a search/replace diff; faster, less bandwidth.
#           Suitable for 16b+ models that handle diffs reliably.
#   whole — model outputs the entire file; safer for smaller models
#           that struggle with partial edits.
#
# num_ctx notes:
#   qwen2.5-coder:32b  ~20GB weights — ~28GB headroom for KV cache at 32k ctx
#   llama3.3:70b       ~40GB weights — ~8GB headroom; keep ctx tighter
#   deepseek-coder-v2:16b ~10GB weights — comfortable at 32k
#   qwen2.5-coder:7b   ~4.5GB weights — fast editor, 16k is ample

- name: ollama/qwen2.5-coder:32b
  num_ctx: 32768
  edit_format: diff

- name: ollama/llama3.3:70b
  num_ctx: 16384
  edit_format: diff

- name: ollama/deepseek-coder-v2:16b
  num_ctx: 32768
  edit_format: diff

- name: ollama/qwen2.5-coder:14b
  num_ctx: 32768
  edit_format: whole

- name: ollama/qwen2.5-coder:7b
  num_ctx: 16384
  edit_format: whole
")
        (save-buffer)
        (message "Created %s" path))))

  (defun aider/create-model-settings ()
    "Create a .aider.model.settings.yml in the current project root.
Sets num_ctx and edit_format appropriate for local Ollama models."
    (interactive)
    (let* ((root (or (projectile-project-root) default-directory))
           (path (expand-file-name ".aider.model.settings.yml" root)))
      (if (file-exists-p path)
          (find-file path)
        (find-file path)
        (insert "\
# Aider per-project model settings
# See: https://aider.chat/docs/config/model-settings.html
#
# Critical for local models: set num_ctx explicitly.
# Ollama defaults to a small context window, causing silent data drops
# where the model forgets the start of your file mid-session.
#
# edit_format: 'whole' forces the model to output the entire file —
# safer for local models that struggle with diff/search-replace format.
# Use 'diff' for stronger models (32b+) that handle it reliably.

- name: ollama/qwen2.5-coder:32b
  num_ctx: 32768
  edit_format: diff

- name: ollama/qwen2.5-coder:14b
  num_ctx: 32768
  edit_format: whole

- name: ollama/qwen2.5-coder:7b
  num_ctx: 16384
  edit_format: whole

- name: ollama/deepseek-coder-v2:16b
  num_ctx: 32768
  edit_format: diff
")
        (save-buffer)
        (message "Created %s" path))))

  :bind
  ;; Using C-c A (capital) to avoid clashing with ai-code-interface's C-c a.
  ;; Adjust if you prefer a different prefix.
  ("C-c A" . aider-transient-menu))


;;; Companion file: .aider.conf.yml (project root or ~/.aider.conf.yml)
;;;
;;; Aider reads a YAML config file for persistent settings. The snippet
;;; below shows the key options relevant to your setup. Create it with:
;;;   M-x aider/create-conf  (defined below the use-package block)
;;;
;;; ---
;;; # ~/.aider.conf.yml — global Aider defaults
;;; # model: ollama/qwen2.5-coder:32b   # overridden by aider-args in Emacs
;;; no-auto-commits: true               # always review before committing
;;; git: true                           # track changes in git
;;; auto-lint: true                     # run linter after edits
;;; auto-test: false                    # don't auto-run tests (you'll run them)
;;; show-diffs: true                    # show diffs before applying
;;; pretty: true                        # colored output in terminal
;;; stream: true                        # stream responses (faster feel)
;;; map-tokens: 2048                    # repo map token budget
;;;                                     # increase for large projects
;;; map-refresh: auto                   # refresh repo map as needed

(defun aider/create-conf ()
  "Create a ~/.aider.conf.yml with sensible defaults."
  (interactive)
  (let ((path (expand-file-name "~/.aider.conf.yml")))
    (if (file-exists-p path)
        (progn (find-file path)
               (message "~/.aider.conf.yml already exists — opened for editing"))
      (find-file path)
      (insert "\
# ~/.aider.conf.yml — global Aider defaults
# https://aider.chat/docs/config/aider_conf.html
#
# Note: aider-args in your Emacs config overrides --model here,
# but other settings are picked up from this file.

no-auto-commits: true     # always review git commits before they land
git: true                 # track changes in git
auto-lint: true           # run linter (flymake/flycheck picks up results)
auto-test: false          # don't auto-run tests; trigger manually
show-diffs: true          # show diffs before applying edits
pretty: true              # colored terminal output
stream: true              # stream responses token by token
map-tokens: 2048          # repo-map token budget; raise for large projects
map-refresh: auto         # refresh repo map as files change
")
      (save-buffer)
      (message "Created %s" path))))
