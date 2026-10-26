;;; codex-transcript-test.el --- Transcript behavior checks -*- lexical-binding: t; -*-
(require 'ert)
(require 'cl-lib)
(unless (featurep 'my-codex-transcript)
  (load (expand-file-name "../codex-transcript.el"
                          (file-name-directory (or load-file-name buffer-file-name))) nil t))

(ert-deftest my/codex-transcript-test--terminal-keymap-precedence ()
  (with-temp-buffer
    (rename-buffer "*codex[keymap-test]*" t)
    (setq-local ghostel--char-mode-override-active t)
    (use-local-map ghostel-char-mode-map)
    (my/codex-enable-command-keys)
    (should (eq (key-binding (kbd "C-c x T")) #'my/codex-view-transcript))
    (should (eq (key-binding (kbd "C-c x t")) #'codex-toggle))
    (should (eq (key-binding (kbd "S-<f8>")) #'my/codex-view-transcript))
    (should (eq (key-binding (kbd "C-u")) #'universal-argument))
    ;; Ordinary typing and Ghostel's input controls still reach the terminal.
    (should (eq (key-binding (kbd "RET")) #'ghostel--send-event))
    (should (eq (key-binding (kbd "M-<return>")) #'ghostel-semi-char-mode)))
  (with-temp-buffer
    (my/codex-enable-command-keys)
    (should-not my/codex-keys-active)))

(defun my/codex-transcript-test--message (role text &optional phase)
  (list :type "response_item"
        :payload (list :type "message" :role role :phase phase
                       :content (list (list :type "output_text" :text text)))))

(ert-deftest my/codex-transcript-test--messages-and-internal-context ()
  (should (equal (substring-no-properties
                  (my/codex-transcript--render-line
                   (my/codex-transcript-test--message "user" "hello")))
                 "You: hello"))
  (should (equal (substring-no-properties
                  (my/codex-transcript--render-line
                   (my/codex-transcript-test--message "assistant" "world" "final")))
                 "Codex: world"))
  (dolist (record (list (my/codex-transcript-test--message "developer" "internal")
                        (my/codex-transcript-test--message "system" "internal")
                        (my/codex-transcript-test--message "assistant" "internal" "analysis")
                        '(:type "event_msg" :payload (:type "agent_message" :message "mirror"))
                        '(:type "response_item" :payload (:type "reasoning" :summary "internal"))))
    (should-not (my/codex-transcript--render-line record)))
  (should-not (my/codex-transcript--parse-line "{partial")))

(ert-deftest my/codex-transcript-test--tool-calls-and-lossless-folding ()
  (let* ((my/codex-transcript-tool-use-max 8)
         (call '(:type "response_item" :payload
                        (:type "function_call" :name "exec_command"
                               :arguments "{\"cmd\":\"echo first\\necho second\"}")))
         (rendered (my/codex-transcript--render-line call)))
    (should (string-match-p "exec_command" rendered))
    (with-temp-buffer
      (my/codex-transcript-mode)
      (let ((inhibit-read-only t)) (insert rendered))
      (goto-char (point-min))
      (forward-line 1)
      (my/codex-transcript-toggle-block)
      (should (string-match-p "echo second" (buffer-string)))
      (my/codex-transcript-toggle-block)
      (should (string-match-p "TAB to expand" (buffer-string)))))
  (dolist (type '("custom_tool_call" "custom_tool_call_output" "function_call_output"))
    (should (my/codex-transcript--render-line
             (list :type "response_item" :payload
                   (list :type type :name "functions.exec" :input "code" :output "result"))))))

(ert-deftest my/codex-transcript-test--fragmented-live-records ()
  (let ((buffer (generate-new-buffer " *codex-transcript-test*"))
        (my/codex-transcript-flush-interval nil)
        process)
    (unwind-protect
        (with-current-buffer buffer
          (my/codex-transcript-mode)
          (setq process (make-pipe-process :name "codex-transcript-test" :buffer buffer :noquery t))
          (let* ((line (concat (json-serialize
                               '(:type "response_item" :payload
                                       (:type "message" :role "assistant" :content
                                              [(:type "output_text" :text "complete")])) ) "\n"))
                 (cut (/ (length line) 2)))
            (my/codex-transcript--filter process (substring line 0 cut))
            (should (zerop (buffer-size)))
            (my/codex-transcript--filter process (substring line cut))
            (should (equal (buffer-string) "Codex: complete\n\n"))
            (should (equal my/codex-transcript--pending ""))))
      (when (and process (process-live-p process)) (delete-process process))
      (kill-buffer buffer))))

(ert-deftest my/codex-transcript-test--project-session-selection ()
  (let* ((root (make-temp-file "codex-transcript-project-" t))
         (other (make-temp-file "codex-transcript-other-" t))
         (my/codex-transcript-sessions-directory (make-temp-file "codex-transcript-sessions-" t))
         (first (expand-file-name "first.jsonl" my/codex-transcript-sessions-directory))
         (second (expand-file-name "second.jsonl" my/codex-transcript-sessions-directory))
         (unrelated (expand-file-name "other.jsonl" my/codex-transcript-sessions-directory)))
    (unwind-protect
        (progn
          (dolist (entry (list (cons first root) (cons second root) (cons unrelated other)))
            (with-temp-file (car entry)
              (insert (json-serialize (list :type "session_meta" :payload (list :cwd (cdr entry)))) "\n")))
          (set-file-times first (seconds-to-time 10))
          (set-file-times second (seconds-to-time 20))
          (should (equal (my/codex-transcript--sessions root) (list second first)))
          (let ((default-directory root)
                (codex--session-transcript-file first))
            (cl-letf (((symbol-function 'my/codex-transcript--project-root) (lambda () root))
                      ((symbol-function 'pop-to-buffer) (lambda (buffer &rest _) buffer)))
              (let ((buf (my/codex-view-transcript)))
                (unwind-protect
                    (with-current-buffer buf
                      (should (equal my/codex-transcript--file first))
                      (should (equal (process-command (get-buffer-process buf))
                                     (list "tail" "-n" "+1" "-f" first))))
                  (kill-buffer buf))))))
      (delete-directory root t)
      (delete-directory other t)
      (delete-directory my/codex-transcript-sessions-directory t))))

(ert-deftest my/codex-transcript-test--prefix-picks-another-session ()
  (let* ((root (make-temp-file "codex-transcript-pick-" t))
         (current (expand-file-name "current.jsonl" root))
         (chosen (expand-file-name "chosen.jsonl" root)))
    (unwind-protect
        (progn
          (with-temp-file current (insert "\n"))
          (with-temp-file chosen (insert "\n"))
          (cl-letf (((symbol-function 'my/codex-transcript--project-root) (lambda () root))
                    ((symbol-function 'my/codex-transcript--current-file) (lambda () current))
                    ((symbol-function 'my/codex-transcript--sessions) (lambda (&optional _) (list current chosen)))
                    ((symbol-function 'completing-read) (lambda (_prompt choices &rest _) (caar (last choices))))
                    ((symbol-function 'pop-to-buffer) (lambda (buffer &rest _) buffer)))
            (let ((buf (my/codex-view-transcript t)))
              (unwind-protect
                  (with-current-buffer buf (should (equal my/codex-transcript--file chosen)))
                (kill-buffer buf)))))
      (delete-directory root t))))
