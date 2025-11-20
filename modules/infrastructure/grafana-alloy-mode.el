;;; grafana-alloy-mode.el --- Major mode for Grafana Alloy configuration -*- lexical-binding: t -*-

;; Copyright (C) bgcartman
;; Author: bgcartman
;; Version: 0.0.1 ; Updated version
;; Keywords: languages grafana alloy configuration format
;; Package-Requires: ((emacs "25.1"))
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; Provides a basic major mode for editing Grafana Alloy configuration files (.alloy).
;; Includes basic syntax highlighting, indentation support, and integration with `alloy fmt`.

;;; Code:

(eval-when-compile
  (require 'imenu)
  (require 'tramp))

(defgroup grafana-alloy nil
  "Major mode settings for Grafana Alloy configuration files."
  :group 'languages
  :prefix "grafana-alloy-")

;; --- Customization Variables ---

(defcustom grafana-alloy-tab-width 2
  "The TAB width for Grafana Alloy blocks."
  :type 'integer
  :group 'grafana-alloy)

(defcustom grafana-alloy-format-on-save nil
  "If non-nil, automatically format the buffer using `alloy fmt` on save."
  :type 'boolean
  :group 'grafana-alloy)

(defcustom grafana-alloy-mode-line "[GA]"
  "Grafana alloy mode line segment."
  :type 'string
  :group 'grafana-alloy)

;; --- Regular Expressions for Font Lock ---

;; String Interpolation
(defconst grafana-alloy--string-interpolation-regexp
  "\\${[^}\n\\\\]*\\(?:\\\\.[^}\n\\\\]*\\)*}"
  "Regexp matching string interpolation like ${...}.")

(defconst grafana-alloy--assignment-regexp
  "\\s-*\\([[:word:]._]+\\)\\s-*=" ; Match identifier followed by =, capture identifier
  "Regexp matching assignments like `ident = ...`, capturing `ident`.")

(defconst grafana-alloy--map-regexp
  "\\s-*\\([[:word:]._]+\\)\\s-*\\(?:\"\\([^\"]+\\)\"\\s-*\\)?{" ; Match block_type ["label"] {
  "Regexp matching block definitions like `type {` or `type \"label\" {`.")

(defconst grafana-alloy--boolean-regexp
  (concat "\\b" (regexp-opt '("true" "false" "on" "off" "yes" "no") t) "\\b")
  "Regexp matching boolean literals.")

(defvar grafana-alloy-font-lock-keywords
  `(;; Assignment: `variable = value`
    (,grafana-alloy--assignment-regexp 1 font-lock-variable-name-face)
    ;; Block Type: `type ["label"] {`
    (,grafana-alloy--map-regexp 1 font-lock-type-face)       ; Block Type
    (,grafana-alloy--map-regexp 2 font-lock-string-face nil t) ; Optional Label
    ;; Boolean literals
    (,grafana-alloy--boolean-regexp . font-lock-constant-face)
    ;; String Interpolation: `${...}`
    (,grafana-alloy--string-interpolation-regexp 0 font-lock-variable-name-face t))
  "Font lock keywords for Grafana Alloy mode.")

;; --- Indentation Helper Functions ---
(defun grafana-alloy-mode-indent-line ()
  "Indent current line for Alloy mode."
  (interactive)
  (let ((indent-level 0)
	(pos-in-indent (- (current-column) (current-indentation))))
    (save-excursion
      ;; Go to beginning of line
      (beginning-of-line)
      (let ((line-start (point)))
	;; Go backward to determine indentation level
	(condition-case nil
	    (while t
	      (backward-up-list 1)
	      (when (looking-at "{")
		(setq indent-level (+ indent-level 1))))
	  (error nil))

	;; Check if current line has closing brace at start (after whitespace)
	(goto-char line-start)
	(when (looking-at "[ \t]*}")
	  (setq indent-level (max 0 (- indent-level 1))))

	;; Apply new indentation
	(delete-horizontal-space)
	(if (> indent-level 0)
	    (insert (make-string indent-level ?\t)))))

    ;; If point was within the indentation, move to the new indentation
    ;; Otherwise, preserve position relative to the indentation
    (if (< pos-in-indent 0)
	(move-to-column (current-indentation))
      (move-to-column (+ (current-indentation) pos-in-indent)))))

;; --- Formatting ---
(defun alloy--remote-tmpfile ()
  "Return a remote temp file path for TRAMP buffers."
  (let ((prefix (file-remote-p default-directory)))
    (concat prefix "/tmp/alloy-format-" (make-temp-name "") ".alloy")))

(defun alloy-format-buffer ()
  "Format the current buffer using `alloy fmt`. Works with TRAMP."
  (interactive)
  (let* ((is-remote (file-remote-p default-directory))
	 (tmpfile (if is-remote
		      (alloy--remote-tmpfile)
		    (make-temp-file "alloy-format" nil ".alloy")))
	 (real-path (if is-remote
			(tramp-file-name-localname (tramp-dissect-file-name tmpfile))
		      tmpfile))
	 (out-buf (get-buffer-create "*alloy-format-output*"))
	 (err-buf (get-buffer-create "*alloy-format-errors*"))
	 (exit-code 0))

    (when (buffer-live-p out-buf) (with-current-buffer out-buf (erase-buffer)))
    (when (buffer-live-p err-buf) (with-current-buffer err-buf (erase-buffer)))

    ;; ✅ Write full buffer contents (not narrowed!)
    (save-restriction
      (widen)
      (write-region (point-min) (point-max) tmpfile nil 'silent))

    (message "Running: alloy fmt %s" real-path)

    (setq exit-code
	  (process-file "alloy" nil (list out-buf err-buf) nil
			"fmt" "-w" real-path))

    (cond
     ((= exit-code 0)
      (let ((p (point)))
	(erase-buffer)
	(insert-file-contents tmpfile)
	(goto-char p))
      (delete-file tmpfile)
      (kill-buffer out-buf)
      (kill-buffer err-buf)
      (message "Alloy format successful."))
     (t
      (display-buffer err-buf)
      (display-buffer out-buf)
      (error "Alloy formatter failed with exit code %d" exit-code)))))

;; --- Syntax Table Setup ---
(defvar grafana-alloy-mode-syntax-table
  (let ((st (make-syntax-table prog-mode-syntax-table)))
    (modify-syntax-entry ?_ "w" st)
    (modify-syntax-entry ?. "w" st)
    (modify-syntax-entry ?/ ". 124b" st)
    (modify-syntax-entry ?* ". 23"   st)
    (modify-syntax-entry ?\n "> b"  st)
    (modify-syntax-entry ?{ "(}" st)
    (modify-syntax-entry ?} "){" st)
    (modify-syntax-entry ?\[ "(]" st)
    (modify-syntax-entry ?\] ")[" st)
    st)
  "Syntax table for `grafana-alloy-mode`.")


;; --- Major Mode Definition ---
(defun grafana-alloy--setup-format-on-save ()
  "Add or remove the format-on-save hook based on `grafana-alloy-format-on-save`.
This function makes the hook buffer-local."
  (if grafana-alloy-format-on-save
      (add-hook 'before-save-hook #'alloy-format-buffer nil t) ; t makes it buffer-local
    (remove-hook 'before-save-hook #'alloy-format-buffer t))) ; t removes buffer-local hook

;; Helper function to remove the hook when buffer is killed or mode changes
;; Ensures cleanup even if the variable was toggled off.
(defun grafana-alloy--remove-format-on-save-hook ()
  "Remove buffer-local format-on-save hook."
  (remove-hook 'before-save-hook #'alloy-format-buffer t)) ; t ensures only buffer-local is removed

;;;###autoload
(define-derived-mode grafana-alloy-mode prog-mode grafana-alloy-mode-line
  "Major mode for editing Grafana Alloy configuration files (.alloy).

Provides syntax highlighting, indentation, and formatting via `alloy fmt`.
Run M-x alloy-format-buffer to format the current buffer.
Enable `grafana-alloy-format-on-save` to format automatically before saving.

Key bindings:
\\{grafana-alloy-mode-map}"
  :syntax-table grafana-alloy-mode-syntax-table

  (setq-local font-lock-defaults '(grafana-alloy-font-lock-keywords))

  ;; Comment settings
  (setq-local comment-start "// ")
  (setq-local comment-start-skip "\\(?:\\s-*//+\\|/\\*+\\)\\s *")
  (setq-local comment-use-syntax t)

  ;; Indentation
  (setq-local indent-tabs-mode t)
  (setq-local indent-line-function #'grafana-alloy-mode-indent-line)
  (setq-local tab-width grafana-alloy-tab-width)
  ;; (setq-local electric-indent-local t)

  ;; Imenu support
  (setq-local imenu-generic-expression
	      '(("Block" "^\\s-*\\([[:word:]._]+\\)\\s-*\\(?:\"\\([^\"]+\\)\"\\s-*\\)?{" 1)))
  (setq-local imenu-create-index-function #'imenu-default-create-index-function)

  ;; Formatting setup
  (add-hook 'kill-buffer-hook #'grafana-alloy--remove-format-on-save-hook nil t) ; Clean up buffer-local hook
  (grafana-alloy--setup-format-on-save) ; Add buffer-local hook if enabled at mode start
  (when (fboundp 'flymake-mode)
    (add-hook 'flymake-diagnostic-functions #'flymake-alloy nil t))
  )

;; --- Mode Hook and Association ---

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.alloy\\'" . grafana-alloy-mode))

;;; Flymake integration
(defcustom grafana-alloy-flymake-checker
  "alloy"
  "Name of `alloy' executable."
  :type 'string
  :group 'grafana-alloy)

(defcustom grafana-alloy-flymake-checker-args
  '("fmt" "-t")
  "A list of strings to pass to the alloy as arguments."
  :type '(repeat (string :tag "Argument"))
  :group 'grafana-alloy)

(defvar-local flymake-alloy--proc nil)

(defun flymake-alloy (report-fn &rest _args)
  "Flymake backend for alloy report using REPORT-FN."
  (if (not grafana-alloy-flymake-checker)
      (error "No alloy program name set"))
  (let ((flymake-alloy--executable-path (executable-find grafana-alloy-flymake-checker)))
    (if (or (null flymake-alloy--executable-path)
	    (not (file-executable-p flymake-alloy--executable-path)))
	(error "Could not find '%s' executable" grafana-alloy-flymake-checker))
    (when (process-live-p flymake-alloy--proc)
      (kill-process flymake-alloy--proc)
      (setq flymake-alloy--proc nil))
    (let ((source (current-buffer)))
      (save-restriction
	(widen)
	(setq
	 flymake-alloy--proc
	 (make-process
	  :name "flymake-alloy" :noquery t :connection-type 'pipe
	  :buffer (generate-new-buffer " *flymake-alloy*")
	  :command `(,flymake-alloy--executable-path ,@grafana-alloy-flymake-checker-args "-")
	  :sentinel
	  (lambda (proc _event)
	    (when (eq 'exit (process-status proc))
	      (unwind-protect
		  (if (with-current-buffer source (eq proc flymake-alloy--proc))
		      (with-current-buffer (process-buffer proc)
			(goto-char (point-min))
			(let ((diags))
			  (while (search-forward-regexp "^\\([^:]+\\):\\([0-9]+\\):\\([0-9]+\\): \\(.*\\)$" nil t)
			    (let ((region (flymake-diag-region source (string-to-number (match-string 2)) (string-to-number (match-string 3)))))
			      ;; expect `region' to only have 2 values (start . end)
			      (push (flymake-make-diagnostic source
							     (car region)
							     (cdr region)
							     :error
							     (match-string 4)) diags)))
			  (funcall report-fn (reverse diags))))
		    (flymake-log :warning "Canceling obsolete check %s" proc))
		(kill-buffer (process-buffer proc)))))))
	(process-send-region flymake-alloy--proc (point-min) (point-max))
	(process-send-eof flymake-alloy--proc)))))


(provide 'grafana-alloy-mode)

;;; grafana-alloy-mode.el ends here
