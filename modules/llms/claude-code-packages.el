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
  ;; (setq claude-code-ide-terminal-backend 'vterm)
  (setq claude-code-ide-terminal-backend 'eat)
  ;; (setq claude-code-ide-terminal-backend 'ghostel)

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

  ;; ;; Unlimited eat scrollback so Claude's normal-screen output (startup
  ;; ;; banners, errors, anything printed outside the TUI's alternate screen)
  ;; ;; stays scrollable instead of being truncated at eat's default cap.
  ;; ;; NOTE: the TUI itself renders in the alternate screen buffer, which is
  ;; ;; never added to scrollback by design — this maximizes what *is* capturable.
  ;; (with-eval-after-load 'eat
  ;;   (setq eat-term-scrollback-size 500000))

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

  ;; Maximize/restore the Claude Code IDE window to fill the whole frame.
  ;; It's a side window, so Emacs refuses plain `delete-other-windows' on
  ;; it ("Cannot make side window the only window"), and its
  ;; `no-delete-other-windows' parameter means C-x 1 from elsewhere leaves
  ;; it alone too. `delete-other-windows-internal' is the primitive that
  ;; `delete-other-windows' itself calls after those checks pass, so it
  ;; skips both guards. Toggle back by restoring the saved layout.
  (defvar my/claude-code-ide--saved-window-configs nil
    "Alist of (FRAME . WINDOW-CONFIGURATION) saved before maximizing.")

  (defun my/claude-code-ide--window ()
    "Return the window showing a Claude Code IDE buffer on the selected frame."
    (seq-find (lambda (win)
                (string-prefix-p "*claude-code[" (buffer-name (window-buffer win))))
              (window-list)))

  (defun my/claude-code-ide-toggle-maximize ()
    "Toggle the Claude Code IDE window filling the whole frame."
    (interactive)
    (if-let ((saved (assq (selected-frame) my/claude-code-ide--saved-window-configs)))
        (progn
          (set-window-configuration (cdr saved))
          (setq my/claude-code-ide--saved-window-configs
                (assq-delete-all (selected-frame) my/claude-code-ide--saved-window-configs)))
      (let ((win (my/claude-code-ide--window)))
        (unless win
          (user-error "No Claude Code IDE window on this frame"))
        (push (cons (selected-frame) (current-window-configuration))
              my/claude-code-ide--saved-window-configs)
        (select-window win)
        (delete-other-windows-internal win))))

  ;; Surface the toggle in the built-in transient menu too, next to the
  ;; other window commands.
  (with-eval-after-load 'claude-code-ide-transient
    (transient-append-suffix 'claude-code-ide-menu "W"
      '("m" "Toggle maximize window" my/claude-code-ide-toggle-maximize)))

  :bind
  (("C-c C-'" . claude-code-ide-menu)   ; transient menu with all commands
   ("<f9>" . my/claude-code-ide-toggle-maximize)))


;;; ============================================================
;;; Live transcript viewer for Claude Code CLI session logs
;;;
;;; Every `claude' CLI session — in Emacs or a plain terminal, any
;;; terminal backend — streams its full transcript to a JSONL file at
;;; ~/.claude/projects/<sanitized-cwd>/<session-id>.jsonl as it runs.
;;; The interactive TUI paints in the terminal's alternate screen,
;;; which no terminal emulator's scrollback captures (that's why
;;; bumping eat/vterm/ghostel scrollback size never helps); this reads
;;; the on-disk transcript instead, so it's backend-independent.
;;; ============================================================

(defgroup my/claude-transcript nil
  "Live viewer for Claude Code CLI session transcripts."
  :group 'tools)

(defcustom my/claude-transcript-lines 200
  "Number of trailing lines to preload when opening a transcript."
  :type 'integer
  :group 'my/claude-transcript)

(defcustom my/claude-transcript-tool-use-max 1200
  "Characters of a tool_use input to show before folding the remainder.
Nothing is discarded: the complete text is kept on a text property, so
press TAB (or RET) on a folded block to expand it in place.  nil shows
every input in full and never folds."
  :type '(choice (const :tag "Never fold" nil) integer)
  :group 'my/claude-transcript)

(defcustom my/claude-transcript-tool-result-max 2000
  "Characters of a tool_result to show before folding the remainder.
See `my/claude-transcript-tool-use-max' — folding is reversible with TAB.
nil shows every result in full and never folds."
  :type '(choice (const :tag "Never fold" nil) integer)
  :group 'my/claude-transcript)

(defface my/claude-transcript-user-face
  '((t :inherit font-lock-keyword-face :weight bold))
  "Face for the \"You:\" label in the Claude transcript viewer.")

(defface my/claude-transcript-assistant-face
  '((t :inherit font-lock-function-name-face :weight bold))
  "Face for the \"Claude:\" label in the Claude transcript viewer.")

(defface my/claude-transcript-tool-face
  '((t :inherit font-lock-comment-face))
  "Face for tool-use/tool-result lines in the Claude transcript viewer.")

(defun my/claude-transcript--sanitize-path (path)
  "Sanitize PATH the way the Claude Code CLI names its project directories."
  (replace-regexp-in-string "[/.]" "-" (directory-file-name (expand-file-name path))))

(defun my/claude-transcript--project-root ()
  "Return the current project root, or `default-directory' if there is none."
  (if-let ((proj (project-current)))
      (project-root proj)
    default-directory))

(defun my/claude-transcript--dir (&optional root)
  "Return the ~/.claude/projects directory holding transcripts for ROOT."
  (expand-file-name (my/claude-transcript--sanitize-path
                      (or root (my/claude-transcript--project-root)))
                     "~/.claude/projects/"))

(defun my/claude-transcript--sessions (&optional root)
  "Return session JSONL files for ROOT's project, newest first."
  (let ((dir (my/claude-transcript--dir root)))
    (sort (and (file-directory-p dir) (directory-files dir t "\\.jsonl\\'"))
          (lambda (a b)
            (time-less-p (file-attribute-modification-time (file-attributes b))
                         (file-attribute-modification-time (file-attributes a)))))))

(defun my/claude-transcript--parse-line (line)
  "Parse one JSONL LINE, returning a plist or nil on malformed input."
  (condition-case nil
      (json-parse-string line :object-type 'plist :array-type 'list
                          :null-object nil :false-object nil)
    (error nil)))

(defun my/claude-transcript--scalar (value)
  "Render a scalar JSON VALUE as display text."
  (cond ((stringp value) value)
        ((null value) "")
        ((eq value t) "true")
        ((numberp value) (number-to-string value))
        (t (format "%S" value))))

(defun my/claude-transcript--format-json (value)
  "Render a parsed JSON VALUE as readable text rather than `prin1' syntax.
Objects become \"key: value\" lines, arrays one element per line, and
nested structures are indented.  This is what keeps a multi-line shell
command readable instead of collapsing it into a `%S' plist dump."
  (cond
   ((null value) "")
   ((stringp value) value)
   ;; JSON object -> plist with keyword keys
   ((keywordp (car-safe value))
    (let (parts)
      (while value
        (let ((key (substring (symbol-name (car value)) 1))
              (val (cadr value)))
          (push (format "%s: %s" key
                        (if (and (listp val) val)
                            (replace-regexp-in-string
                             "\n" "\n  " (my/claude-transcript--format-json val))
                          (my/claude-transcript--scalar val)))
                parts))
        (setq value (cddr value)))
      (mapconcat #'identity (nreverse parts) "\n")))
   ;; JSON array
   ((listp value)
    (mapconcat #'my/claude-transcript--format-json value "\n"))
   (t (my/claude-transcript--scalar value))))

(defun my/claude-transcript--fold (text limit)
  "Return TEXT for display, folding it to LIMIT characters if longer.
The full text is stored on the `my/claude-transcript-full' property of the
result, so folding is lossless and reversible via
`my/claude-transcript-toggle-block'.  A nil LIMIT returns TEXT unchanged."
  (if (or (null limit) (<= (length text) limit))
      text
    (propertize (concat (substring text 0 limit)
                        (propertize (format " …[+%d chars — TAB to expand]"
                                            (- (length text) limit))
                                    'face 'warning))
                'my/claude-transcript-full text
                'my/claude-transcript-folded t
                'my/claude-transcript-limit limit)))

(defun my/claude-transcript--format-content-block (block)
  "Return a propertized string for a tool_use/tool_result content BLOCK, or nil to skip."
  (pcase (plist-get block :type)
    ("text"
     (let ((text (plist-get block :text)))
       (and text (not (string-empty-p text)) text)))
    ("tool_use"
     (concat (propertize (format "→ %s\n" (plist-get block :name))
                          'face 'my/claude-transcript-tool-face)
             (my/claude-transcript--fold
              (propertize (my/claude-transcript--format-json (plist-get block :input))
                          'face 'shadow)
              my/claude-transcript-tool-use-max)))
    ("tool_result"
     (concat (propertize "← result: " 'face 'my/claude-transcript-tool-face)
             (my/claude-transcript--fold
              (propertize (my/claude-transcript--format-json (plist-get block :content))
                          'face 'my/claude-transcript-tool-face)
              my/claude-transcript-tool-result-max)))
    (_ nil)))

(defun my/claude-transcript--render-line (parsed)
  "Return a display string for one PARSED JSONL event, or nil to skip it."
  (let* ((type (plist-get parsed :type))
         (message (plist-get parsed :message))
         (content (and message (plist-get message :content))))
    (cond
     ((equal type "user")
      (if (stringp content)
          (concat (propertize "You: " 'face 'my/claude-transcript-user-face) content)
        (mapconcat #'identity
                   (delq nil (mapcar #'my/claude-transcript--format-content-block content))
                   "\n")))
     ((equal type "assistant")
      (mapconcat #'identity
                 (delq nil (mapcar (lambda (block)
                                     (if (equal (plist-get block :type) "text")
                                         (concat (propertize "Claude: "
                                                              'face 'my/claude-transcript-assistant-face)
                                                 (plist-get block :text))
                                       (my/claude-transcript--format-content-block block)))
                                   content))
                 "\n"))
     (t nil))))

(defvar-local my/claude-transcript--pending ""
  "Unterminated tail of the last chunk read from the tail process.")

(defun my/claude-transcript--insert-line (line)
  "Parse LINE and, if it renders to something, append it to the current buffer.
Windows already scrolled to the end follow the new text; windows
scrolled back to read history are left alone."
  (let* ((parsed (my/claude-transcript--parse-line line))
         (text (and parsed (my/claude-transcript--render-line parsed))))
    (when (and text (not (string-empty-p text)))
      (let ((inhibit-read-only t)
            (old-max (point-max))
            (windows (get-buffer-window-list (current-buffer) nil t)))
        (save-excursion
          (goto-char (point-max))
          (insert text "\n\n"))
        (dolist (win windows)
          (when (= (window-point win) old-max)
            (set-window-point win (point-max))))))))

(defun my/claude-transcript--filter (proc chunk)
  "Process filter that buffers partial lines and renders complete ones."
  (when (buffer-live-p (process-buffer proc))
    (with-current-buffer (process-buffer proc)
      (setq my/claude-transcript--pending (concat my/claude-transcript--pending chunk))
      (let ((lines (split-string my/claude-transcript--pending "\n")))
        (setq my/claude-transcript--pending (car (last lines)))
        (dolist (line (butlast lines))
          (unless (string-empty-p line)
            (my/claude-transcript--insert-line line)))))))

(defun my/claude-transcript--cleanup ()
  "Kill this buffer's tail process, if any. Meant for `kill-buffer-hook'."
  (when-let ((proc (get-buffer-process (current-buffer))))
    (when (process-live-p proc)
      (delete-process proc))))

(defun my/claude-transcript--block-bounds (pos)
  "Return (START . END) of the folded-block property run covering POS."
  (let ((start pos) (end pos))
    (while (and (> start (point-min))
                (get-text-property (1- start) 'my/claude-transcript-full))
      (setq start (1- start)))
    (while (and (< end (point-max))
                (get-text-property end 'my/claude-transcript-full))
      (setq end (1+ end)))
    (cons start end)))

(defun my/claude-transcript-toggle-block ()
  "Expand, or re-fold, the elided transcript block on the current line.
Folded blocks carry their complete text on a text property, so this never
has to re-read the transcript file."
  (interactive)
  (let ((pos (if (get-text-property (point) 'my/claude-transcript-full)
                 (point)
               (let ((next (next-single-property-change
                            (line-beginning-position) 'my/claude-transcript-full
                            nil (line-end-position))))
                 (and next
                      (get-text-property next 'my/claude-transcript-full)
                      next)))))
    (unless pos
      (user-error "No expandable block on this line"))
    (let* ((full (get-text-property pos 'my/claude-transcript-full))
           (folded (get-text-property pos 'my/claude-transcript-folded))
           (face (get-text-property pos 'face))
           (limit (get-text-property pos 'my/claude-transcript-limit))
           (bounds (my/claude-transcript--block-bounds pos))
           (inhibit-read-only t)
           (replacement
            (if folded
                (propertize full
                            'face face
                            'my/claude-transcript-full full
                            'my/claude-transcript-folded nil
                            'my/claude-transcript-limit limit)
              (my/claude-transcript--fold (propertize full 'face face) limit))))
      (save-excursion
        (goto-char (car bounds))
        (delete-region (car bounds) (cdr bounds))
        (insert replacement)))))

(define-derived-mode my/claude-transcript-mode special-mode "Claude-Transcript"
  "Major mode for the live Claude Code transcript viewer."
  (setq buffer-read-only t)
  (setq-local truncate-lines nil))

(define-key my/claude-transcript-mode-map (kbd "TAB") #'my/claude-transcript-toggle-block)
(define-key my/claude-transcript-mode-map (kbd "RET") #'my/claude-transcript-toggle-block)

(defun my/claude-code-view-transcript (&optional pick)
  "Open a live-updating view of the current project's Claude Code transcript.
With a prefix argument, choose which session to view instead of
defaulting to the most recently active one."
  (interactive "P")
  (let* ((root (my/claude-transcript--project-root))
         (sessions (my/claude-transcript--sessions root))
         (file (if (not sessions)
                   (user-error "No Claude Code transcripts found for %s"
                               (my/claude-transcript--dir root))
                 (if pick
                     (let ((choices
                            (mapcar (lambda (f)
                                      (cons (format "%s  (%s)"
                                                    (file-name-base f)
                                                    (format-time-string
                                                     "%Y-%m-%d %H:%M"
                                                     (file-attribute-modification-time
                                                      (file-attributes f))))
                                            f))
                                    sessions)))
                       (cdr (assoc (completing-read "Session: " choices nil t) choices)))
                   (car sessions))))
         (bufname (format "*claude-transcript: %s*"
                           (file-name-nondirectory (directory-file-name root))))
         (buf (get-buffer bufname)))
    (if (and buf
             (get-buffer-process buf)
             (process-live-p (get-buffer-process buf))
             (equal (process-get (get-buffer-process buf) 'transcript-file) file))
        (pop-to-buffer buf)
      (when buf (kill-buffer buf))
      (setq buf (get-buffer-create bufname))
      (with-current-buffer buf
        (my/claude-transcript-mode)
        (let ((proc (start-process "claude-transcript-tail" buf
                                    "tail" "-n" (number-to-string my/claude-transcript-lines)
                                    "-f" file)))
          (process-put proc 'transcript-file file)
          (set-process-filter proc #'my/claude-transcript--filter)
          (add-hook 'kill-buffer-hook #'my/claude-transcript--cleanup nil t)))
      (pop-to-buffer buf))))

(with-eval-after-load 'claude-code-ide-transient
  (transient-append-suffix 'claude-code-ide-menu "m"
    '("t" "View live transcript" my/claude-code-view-transcript)))

(global-set-key (kbd "<f8>") #'my/claude-code-view-transcript)


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
