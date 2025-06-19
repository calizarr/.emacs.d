;; -*- lexical-binding: t -*-
;; Enable Vertico.
(use-package vertico
  :after consult
  :demand t
  :init
  (vertico-mode)
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-count 20) ;; Show more candidates
  (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy) ; Correct file path when changed
  :config
  ;; ;; Option 1: Additional bindings
  ;; (keymap-set vertico-map "?" #'minibuffer-completion-help)
  ;; (keymap-set vertico-map "M-RET" #'minibuffer-force-complete-and-exit)
  ;; (keymap-set vertico-map "M-TAB" #'minibuffer-complete)

  ;; Option 2: Replace `vertico-insert' to enable TAB prefix expansion.
  (keymap-set vertico-map "TAB" #'minibuffer-complete)
  (setq completion-in-region-function #'consult-completion-in-region)

  (defun +vertico-restrict-to-matches ()
    (interactive)
    (let ((inhibit-read-only t))
      (goto-char (point-max))
      (insert " ")
      (add-text-properties (minibuffer-prompt-end) (point-max)
                           '(invisible t read-only t cursor-intangible t rear-nonsticky t))))

  (define-key vertico-map (kbd "S-SPC") #'+vertico-restrict-to-matches)

  (defun +embark-live-vertico ()
    "Shrink Vertico minibuffer when `embark-live' is active."
    (when-let (win (and (string-prefix-p "*Embark Live" (buffer-name))
                        (active-minibuffer-window)))
      (with-selected-window win
        (when (and (bound-and-true-p vertico--input)
                   (fboundp 'vertico-multiform-unobtrusive))
          (vertico-multiform-unobtrusive)))))

  (add-hook 'embark-collect-mode-hook #'+embark-live-vertico)

  (defvar +vertico-current-arrow t)

  (cl-defmethod vertico--format-candidate :around
    (cand prefix suffix index start &context ((and +vertico-current-arrow
                                                   (not (bound-and-true-p vertico-flat-mode)))
                                              (eql t)))
    (setq cand (cl-call-next-method cand prefix suffix index start))
    (if (bound-and-true-p vertico-grid-mode)
        (if (= vertico--index index)
            (concat #("▶" 0 1 (face vertico-current)) cand)
          (concat #("_" 0 1 (display " ")) cand))
      (if (= vertico--index index)
          (concat
           #(" " 0 1 (display (left-fringe right-triangle vertico-current)))
           cand)
        cand)))

  (defvar +vertico-transform-functions nil)

  (cl-defmethod vertico--format-candidate :around
    (cand prefix suffix index start &context ((not +vertico-transform-functions) null))
    (dolist (fun (ensure-list +vertico-transform-functions))
      (setq cand (funcall fun cand)))
    (cl-call-next-method cand prefix suffix index start))

  (defun +vertico-highlight-directory (file)
    "If FILE ends with a slash, highlight it as a directory."
    (if (string-suffix-p "/" file)
        (propertize file 'face 'marginalia-file-priv-dir) ; or face 'dired-directory
      file))

  ;; function to highlight enabled modes similar to counsel-M-x
  (defun +vertico-highlight-enabled-mode (cmd)
    "If MODE is enabled, highlight it as font-lock-constant-face."
    (let ((sym (intern cmd)))
      (if (or (eq sym major-mode)
              (and
               (memq sym minor-mode-list)
               (boundp sym)))
          (propertize cmd 'face 'font-lock-constant-face)
        cmd)))

  ;; add-to-list works if 'file isn't already in the alist
  ;; setq can be used but will overwrite all existing values
  (add-to-list 'vertico-multiform-categories
               '(file
                 ;; this is also defined in the wiki, uncomment if used
                 ;; (vertico-sort-function . vertico-sort-directories-first)
                 (+vertico-transform-functions . +vertico-highlight-directory)))
  (add-to-list 'vertico-multiform-commands
               '(execute-extended-command
                 reverse
                 (+vertico-transform-functions . +vertico-highlight-enabled-mode)))

  (setq vertico-multiform-commands
        '(("\\`execute-extended-command" unobtrusive
           (vertico-flat-annotate . t)
           (marginalia-annotators (command marginalia-annotate-binding)))))

  (defun vertico--swap-annotations (result)
    ;; Move annotations only for files
    (if minibuffer-completing-file-name
        (mapcar (lambda (x)
                  ;; Swap prefix/suffix annotations
                  (list (car x) (concat (string-trim-left (caddr x)) " ") (cadr x)))
                result)
      result))
  (advice-add #'vertico--affixate :filter-return #'vertico--swap-annotations)

  (defvar previous-directory nil
    "The directory that was just left. It is set when leaving a directory and
    set back to nil once it is used in the parent directory.")

  (defun set-previous-directory ()
    "Set the directory that was just exited from within find-file."
    (when (< (minibuffer-prompt-end) (point))
      (save-excursion
        (goto-char (1- (point)))
        (when (search-backward "/" (minibuffer-prompt-end) t)
          ;; set parent directory
          (setq previous-directory (buffer-substring (1+ (point)) (point-max)))
          ;; set back to nil if not sorting by directories or what was deleted is not a directory
          (when (not (string-suffix-p "/" previous-directory))
            (setq previous-directory nil))
          t))))

  (advice-add #'vertico-directory-up :before #'set-previous-directory)

  (define-advice vertico--update (:after (&rest _) choose-candidate)
    "Pick the previous directory rather than the prompt after updating candidates."
    (cond
     (previous-directory ; select previous directory
      (setq vertico--index (or (seq-position vertico--candidates previous-directory)
                               vertico--index))
      (setq previous-directory nil)))))


;; Configure directory extension.
(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))



;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Prompt indicator for `completing-read-multiple'.
(when (< emacs-major-version 31)
  (advice-add #'completing-read-multiple :filter-args
              (lambda (args)
                (cons (format "[CRM%s] %s"
                              (string-replace "[ \t]*" "" crm-separator)
                              (car args))
                      (cdr args)))))


;; Enable vertico-multiform
(vertico-multiform-mode)

;; Configure the display per command.
;; Use a buffer with indices for imenu
;; and a flat (Ido-like) menu for M-x.
(setq vertico-multiform-commands
      '((consult-imenu buffer indexed)
        (execute-extended-command unobtrusive)))

;; Configure the display per completion category.
;; Use the grid display for files and a buffer
;; for the consult-grep commands.
(setq vertico-multiform-categories
      '((file grid)
        (consult-grep buffer)))
