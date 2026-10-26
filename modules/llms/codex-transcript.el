;;; codex-transcript.el --- Live Codex transcript viewer -*- lexical-binding: t; -*-

;; Adapted from the existing Claude transcript viewer in claude-code-packages.el.
;; Reads canonical rollout records independently of the terminal backend.
(require 'json)
(require 'project)
(require 'seq)
(require 'subr-x)

(defgroup my/codex-transcript nil
  "Live viewer for Codex Code CLI session transcripts."
  :group 'tools)

(defcustom my/codex-transcript-lines nil
  "Trailing JSONL lines to preload, or nil for the full conversation."
  :type '(choice (const :tag "Full conversation" nil) integer)
  :group 'my/codex-transcript)

(defcustom my/codex-transcript-tool-use-max 1200
  "Characters of a tool_use input to show before folding the remainder.
Nothing is discarded: the complete text is kept on a text property, so
press TAB (or RET) on a folded block to expand it in place.  nil shows
every input in full and never folds."
  :type '(choice (const :tag "Never fold" nil) integer)
  :group 'my/codex-transcript)

(defcustom my/codex-transcript-tool-result-max 2000
  "Characters of a tool_result to show before folding the remainder.
See `my/codex-transcript-tool-use-max' — folding is reversible with TAB.
nil shows every result in full and never folds."
  :type '(choice (const :tag "Never fold" nil) integer)
  :group 'my/codex-transcript)

(defcustom my/codex-transcript-flush-interval 0.2
  "Seconds to coalesce incoming transcript lines before rendering them.
The tail process delivers a chunk per write, and while Codex is
streaming that is many per second.  Rendering each one on arrival costs
an insertion and a full redisplay apiece, all of it synchronous inside
the process filter -- which is where the mid-burst freezes came from.
Batching them into one insertion per interval makes redisplay track
output volume instead of chunk count.  nil restores the old synchronous
behavior."
  :type '(choice (const :tag "Render synchronously" nil) number)
  :group 'my/codex-transcript)

(defcustom my/codex-transcript-max-chars nil
  "Trim the viewer buffer once it grows past this many characters.
Whole entries are dropped off the top, oldest first, so redisplay cost
stops tracking session length.  The JSONL file on disk is never touched
-- read it directly to go back further.  nil keeps everything."
  :type '(choice (const :tag "Never trim" nil) integer)
  :group 'my/codex-transcript)

(defface my/codex-transcript-user-face
  '((t :inherit font-lock-keyword-face :weight bold))
  "Face for the \"You:\" label in the Codex transcript viewer.")

(defface my/codex-transcript-assistant-face
  '((t :inherit font-lock-function-name-face :weight bold))
  "Face for the \"Codex:\" label in the Codex transcript viewer.")

(defface my/codex-transcript-tool-face
  '((t :inherit font-lock-comment-face))
  "Face for tool-use/tool-result lines in the Codex transcript viewer.")

(defcustom my/codex-transcript-sessions-directory
  (expand-file-name "sessions/" (or (getenv "CODEX_HOME") "~/.codex/"))
  "Directory containing Codex rollout JSONL files."
  :type 'directory
  :group 'my/codex-transcript)

(defun my/codex-transcript--project-root ()
  "Return the current project root, or `default-directory'."
  (if-let ((proj (project-current nil)))
      (project-root proj)
    default-directory))

(defun my/codex-transcript--session-cwd (file)
  "Read FILE's session metadata without loading its conversation."
  (condition-case nil
      (with-temp-buffer
        (insert-file-contents file nil 0 65536)
        (let ((record (my/codex-transcript--parse-line
                       (buffer-substring-no-properties
                        (point-min) (line-end-position)))))
          (when (equal (plist-get record :type) "session_meta")
            (plist-get (plist-get record :payload) :cwd))))
    (file-error nil)))

(defun my/codex-transcript--sessions (&optional root)
  "Return ROOT's Codex transcripts, most recently modified first."
  (let* ((root (file-name-as-directory (expand-file-name
                                      (or root (my/codex-transcript--project-root)))))
         (dir (expand-file-name my/codex-transcript-sessions-directory))
         (files (and (file-directory-p dir)
                     (directory-files-recursively dir "\\.jsonl\\'"))))
    (sort (seq-filter
           (lambda (file)
             (when-let ((cwd (my/codex-transcript--session-cwd file)))
               (or (equal (file-name-as-directory (expand-file-name cwd)) root)
                   (file-in-directory-p cwd root))))
           files)
          (lambda (a b)
            (time-less-p (file-attribute-modification-time (file-attributes b))
                         (file-attribute-modification-time (file-attributes a)))))))

(defvar-local my/codex-transcript--file nil
  "Canonical JSONL file displayed in this viewer.")

(defun my/codex-transcript--current-file ()
  "Resolve the attached Codex session without asking for an id."
  (let ((file (or my/codex-transcript--file
                  (and (fboundp 'codex--current-session-transcript-file)
                       (codex--current-session-transcript-file))
                  (and (boundp 'codex--session-id)
                       codex--session-id
                       (fboundp 'codex--find-session-transcript)
                       (codex--find-session-transcript codex--session-id)))))
    (and (stringp file) (file-readable-p file) (expand-file-name file))))

(defun my/codex-transcript--parse-line (line)
  "Parse one JSONL LINE, returning a plist or nil on malformed input."
  (condition-case nil
      (json-parse-string line :object-type 'plist :array-type 'list
                          :null-object nil :false-object nil)
    (error nil)))

(defun my/codex-transcript--scalar (value)
  "Render a scalar JSON VALUE as display text."
  (cond ((stringp value) value)
        ((null value) "")
        ((eq value t) "true")
        ((numberp value) (number-to-string value))
        (t (format "%S" value))))

(defun my/codex-transcript--format-json (value)
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
                             "\n" "\n  " (my/codex-transcript--format-json val))
                          (my/codex-transcript--scalar val)))
                parts))
        (setq value (cddr value)))
      (mapconcat #'identity (nreverse parts) "\n")))
   ;; JSON array
   ((listp value)
    (mapconcat #'my/codex-transcript--format-json value "\n"))
   (t (my/codex-transcript--scalar value))))

(defun my/codex-transcript--fold (text limit)
  "Return TEXT for display, folding it to LIMIT characters if longer.
The full text is stored on the `my/codex-transcript-full' property of the
result, so folding is lossless and reversible via
`my/codex-transcript-toggle-block'.  A nil LIMIT returns TEXT unchanged."
  (if (or (null limit) (<= (length text) limit))
      text
    (propertize (concat (substring text 0 limit)
                        (propertize (format " …[+%d chars — TAB to expand]"
                                            (- (length text) limit))
                                    'face 'warning))
                'my/codex-transcript-full text
                'my/codex-transcript-folded t
                'my/codex-transcript-limit limit)))

(defun my/codex-transcript--tool-text (value)
  "Format VALUE, decoding a JSON string when possible."
  (my/codex-transcript--format-json
   (if (stringp value)
       (or (my/codex-transcript--parse-line value) value)
     value)))

(defun my/codex-transcript--render-line (parsed)
  "Render a canonical PARSED rollout record, excluding internal context.
Event mirrors, reasoning, system/developer messages, and usage are skipped."
  (when (equal (plist-get parsed :type) "response_item")
    (let* ((item (plist-get parsed :payload))
           (kind (plist-get item :type))
           (role (plist-get item :role)))
      (cond
       ((and (equal kind "message")
             (member role '("user" "assistant"))
             (not (equal (plist-get item :phase) "analysis"))
             (not (equal (plist-get item :channel) "analysis")))
        (let ((body (mapconcat
                     #'identity
                     (delq nil
                           (mapcar (lambda (part)
                                     (when (member (plist-get part :type)
                                                   '("input_text" "output_text" "text"))
                                       (plist-get part :text)))
                                   (plist-get item :content)))
                     "\n\n")))
          (unless (string-empty-p body)
            (concat (propertize (if (equal role "user") "You: " "Codex: ")
                                'face (if (equal role "user")
                                          'my/codex-transcript-user-face
                                        'my/codex-transcript-assistant-face))
                    body))))
       ((member kind '("function_call" "custom_tool_call"))
        (concat (propertize (format "→ %s\n" (plist-get item :name))
                            'face 'my/codex-transcript-tool-face)
                (my/codex-transcript--fold
                 (my/codex-transcript--tool-text
                  (or (plist-get item :arguments) (plist-get item :input)))
                 my/codex-transcript-tool-use-max)))
       ((member kind '("function_call_output" "custom_tool_call_output"))
        (concat (propertize "← result: " 'face 'my/codex-transcript-tool-face)
                (my/codex-transcript--fold
                 (my/codex-transcript--tool-text (plist-get item :output))
                 my/codex-transcript-tool-result-max)))))))

(defvar-local my/codex-transcript--pending ""
  "Unterminated tail of the last chunk read from the tail process.")

(defvar-local my/codex-transcript--queue nil
  "Rendered blocks awaiting insertion, newest first.")

(defvar-local my/codex-transcript--timer nil
  "Pending flush timer for this buffer, if any.")

(defun my/codex-transcript--trim ()
  "Drop whole entries off the top until the buffer fits `my/codex-transcript-max-chars'.
Cuts on a blank line so a partial rendered block is never left behind.
A window scrolled back into the trimmed region loses its place -- that is
the cost of not letting the buffer grow without bound."
  (when (and my/codex-transcript-max-chars
             (> (buffer-size) my/codex-transcript-max-chars))
    (let ((inhibit-read-only t))
      (save-excursion
        (goto-char (max (point-min) (- (point-max) my/codex-transcript-max-chars)))
        (let ((cut (or (search-forward "\n\n" nil t) (line-beginning-position 2))))
          (delete-region (point-min) cut))))))

(defun my/codex-transcript--flush (buffer)
  "Insert everything queued in BUFFER as a single edit.
One insertion and one window update per flush however many lines
arrived, so a burst of output costs one redisplay instead of dozens.
Windows already scrolled to the end follow the new text; windows
scrolled back to read history are left alone."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (setq my/codex-transcript--timer nil)
      (when my/codex-transcript--queue
        (let* ((text (mapconcat #'identity (nreverse my/codex-transcript--queue) "\n\n"))
               (inhibit-read-only t)
               (old-max (point-max))
               (following nil))
          (setq my/codex-transcript--queue nil)
          ;; Decide who is following before the edit: `my/codex-transcript--trim'
          ;; shifts every position, so window-point cannot be compared afterwards.
          (dolist (win (get-buffer-window-list buffer nil t))
            (when (= (window-point win) old-max)
              (push win following)))
          (save-excursion
            (goto-char (point-max))
            (insert text "\n\n"))
          (my/codex-transcript--trim)
          (dolist (win following)
            (set-window-point win (point-max))))))))

(defun my/codex-transcript--schedule-flush ()
  "Ensure a flush of the current buffer's queue is pending."
  (unless (timerp my/codex-transcript--timer)
    (setq my/codex-transcript--timer
          (run-with-timer my/codex-transcript-flush-interval nil
                          #'my/codex-transcript--flush (current-buffer)))))

(defun my/codex-transcript--filter (proc chunk)
  "Process filter: buffer partial lines, render complete ones, queue the result.
Deliberately does not touch the buffer.  A filter runs synchronously
ahead of redisplay and input, and `read-process-output-max' bounds how
much can land in one call, so insertion is deferred to
`my/codex-transcript--flush'."
  (when (buffer-live-p (process-buffer proc))
    (with-current-buffer (process-buffer proc)
      (setq my/codex-transcript--pending (concat my/codex-transcript--pending chunk))
      (let ((lines (split-string my/codex-transcript--pending "\n")))
        (setq my/codex-transcript--pending (car (last lines)))
        (dolist (line (butlast lines))
          (unless (string-empty-p line)
            (let* ((parsed (my/codex-transcript--parse-line line))
                   (text (and parsed (my/codex-transcript--render-line parsed))))
              (when (and text (not (string-empty-p text)))
                (push text my/codex-transcript--queue))))))
      (if my/codex-transcript-flush-interval
          (my/codex-transcript--schedule-flush)
        (my/codex-transcript--flush (current-buffer))))))

(defun my/codex-transcript--cleanup ()
  "Kill this buffer's tail process and cancel its pending flush.
Meant for `kill-buffer-hook'."
  (when (timerp my/codex-transcript--timer)
    (cancel-timer my/codex-transcript--timer)
    (setq my/codex-transcript--timer nil))
  (when-let ((proc (get-buffer-process (current-buffer))))
    (when (process-live-p proc)
      (delete-process proc))))

(defun my/codex-transcript--block-bounds (pos)
  "Return (START . END) of the folded-block property run covering POS."
  (let ((start pos) (end pos))
    (while (and (> start (point-min))
                (get-text-property (1- start) 'my/codex-transcript-full))
      (setq start (1- start)))
    (while (and (< end (point-max))
                (get-text-property end 'my/codex-transcript-full))
      (setq end (1+ end)))
    (cons start end)))

(defun my/codex-transcript-toggle-block ()
  "Expand, or re-fold, the elided transcript block on the current line.
Folded blocks carry their complete text on a text property, so this never
has to re-read the transcript file."
  (interactive)
  (let ((pos (if (get-text-property (point) 'my/codex-transcript-full)
                 (point)
               (let ((next (next-single-property-change
                            (line-beginning-position) 'my/codex-transcript-full
                            nil (line-end-position))))
                 (and next
                      (get-text-property next 'my/codex-transcript-full)
                      next)))))
    (unless pos
      (user-error "No expandable block on this line"))
    (let* ((full (get-text-property pos 'my/codex-transcript-full))
           (folded (get-text-property pos 'my/codex-transcript-folded))
           (face (get-text-property pos 'face))
           (limit (get-text-property pos 'my/codex-transcript-limit))
           (bounds (my/codex-transcript--block-bounds pos))
           (inhibit-read-only t)
           (replacement
            (if folded
                (propertize full
                            'face face
                            'my/codex-transcript-full full
                            'my/codex-transcript-folded nil
                            'my/codex-transcript-limit limit)
              (my/codex-transcript--fold (propertize full 'face face) limit))))
      (save-excursion
        (goto-char (car bounds))
        (delete-region (car bounds) (cdr bounds))
        (insert replacement)))))

(define-derived-mode my/codex-transcript-mode special-mode "Codex-Transcript"
  "Major mode for the live Codex Code transcript viewer."
  (setq buffer-read-only t)
  (setq-local truncate-lines nil)
  ;; Inherited from `global-display-line-numbers-mode', which turns itself on in
  ;; every non-minibuffer buffer, this one included.  Nothing here has a line
  ;; worth numbering, and the gutter makes redisplay recount lines as the buffer
  ;; grows.  Wrapping stays on deliberately -- horizontal scrolling is worse.
  (display-line-numbers-mode -1)
  ;; Nothing here is editable, so undo records are pure allocation -- and they
  ;; would pin the very text `my/codex-transcript--trim' is trying to drop.
  (setq buffer-undo-list t))

(define-key my/codex-transcript-mode-map (kbd "TAB") #'my/codex-transcript-toggle-block)
(define-key my/codex-transcript-mode-map (kbd "RET") #'my/codex-transcript-toggle-block)

(defun my/codex-view-transcript (&optional pick)
  "View the attached Codex session, or the newest session for this project.
With prefix PICK, choose a project session.  No session id is required.
The full conversation is loaded by default and new records appear live."
  (interactive "P")
  (let* ((root (my/codex-transcript--project-root))
         (current (my/codex-transcript--current-file))
         (sessions (when (or pick (not current))
                     (my/codex-transcript--sessions root)))
         (file
          (if pick
              (let* ((choices
                      (mapcar
                       (lambda (f)
                         (cons (format "%s  (%s)"
                                       (file-name-base f)
                                       (format-time-string
                                        "%Y-%m-%d %H:%M"
                                        (file-attribute-modification-time (file-attributes f))))
                               f))
                       (delete-dups (append (and current (list current)) sessions)))))
                (unless choices (user-error "No Codex transcripts for %s" root))
                (cdr (assoc (completing-read "Codex session: " choices nil t) choices)))
            (or current (car sessions)
                (user-error "No Codex transcripts for %s" root))))
         (bufname (format "*codex-transcript: %s*" (file-name-base file)))
         (buf (get-buffer-create bufname)))
    (unless (and (get-buffer-process buf)
                 (process-live-p (get-buffer-process buf)))
      (with-current-buffer buf
        (my/codex-transcript--cleanup)
        (let ((inhibit-read-only t)) (erase-buffer))
        (my/codex-transcript-mode)
        (setq default-directory root
              my/codex-transcript--file file
              header-line-format (concat "Codex transcript · " (file-name-base file)
                                         " · live · TAB expands tools"))
        (add-hook 'kill-buffer-hook #'my/codex-transcript--cleanup nil t)
        (let ((proc (make-process
                     :name "codex-transcript-tail" :buffer buf :noquery t
                     :coding 'utf-8-unix :connection-type 'pipe
                     :command (list "tail" "-n"
                                    (if my/codex-transcript-lines
                                        (number-to-string my/codex-transcript-lines)
                                      "+1")
                                    "-f" file)
                     :filter #'my/codex-transcript--filter
                     :sentinel (lambda (_process _event) nil))))
          (process-put proc 'transcript-file file))))
    (pop-to-buffer buf)))

;; Mirror Claude's F8 viewer while retaining its binding and Codex's window toggle.
(global-set-key (kbd "S-<f8>") #'my/codex-view-transcript)
(defvar-local my/codex-keys-active nil
  "Whether the Codex command prefix overrides terminal character handling.")

(defvar my/codex-keys-map (make-sparse-keymap)
  "Codex keys that must remain available inside terminal buffers.")

(defvar my/codex-keys-emulation-alist
  `((my/codex-keys-active . ,my/codex-keys-map))
  "Codex-only overrides above terminal emulation maps.")

(defun my/codex-enable-command-keys ()
  "Enable command keys in Codex buffers, including ai-code terminals."
  (when (string-match-p "\\`\\*codex[[:punct:]]" (buffer-name))
    (setq-local my/codex-keys-active t)
    (setq emulation-mode-map-alists
          (cons 'my/codex-keys-emulation-alist
                (remq 'my/codex-keys-emulation-alist emulation-mode-map-alists)))))

(with-eval-after-load 'codex
  (define-key codex-command-map (kbd "T") #'my/codex-view-transcript)
  (global-set-key (kbd "C-c x") codex-command-map)
  (define-key my/codex-keys-map (kbd "C-c x") codex-command-map)
  (define-key my/codex-keys-map (kbd "S-<f8>") #'my/codex-view-transcript)
  ;; Allow C-u Shift-F8 / C-u C-c x T to open the session picker.
  (define-key my/codex-keys-map (kbd "C-u") #'universal-argument))

(dolist (hook '(ghostel-mode-hook eat-mode-hook vterm-mode-hook))
  (add-hook hook #'my/codex-enable-command-keys))
(dolist (buffer (buffer-list))
  (with-current-buffer buffer (my/codex-enable-command-keys)))

(provide 'my-codex-transcript)
;;; codex-transcript.el ends here
