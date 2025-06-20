;; -*- lexical-binding: t -*-
;; Enable Vertico.
(use-package vertico
  :after consult
  :demand t
  :init
  (vertico-mode +1)
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy) ; Correct file path when changed
  :config
  ;; ;; Option 1: Additional bindings
  (keymap-set vertico-map "?" #'minibuffer-completion-help)
  (keymap-set vertico-map "M-RET" #'minibuffer-force-complete-and-exit)
  (keymap-set vertico-map "M-TAB" #'minibuffer-complete)

  (setq completion-in-region-function #'consult-completion-in-region)

  (defun +vertico-restrict-to-matches ()
    (interactive)
    (let ((inhibit-read-only t))
      (goto-char (point-max))
      (insert " ")
      (add-text-properties (minibuffer-prompt-end) (point-max)
                           '(invisible t read-only t cursor-intangible t rear-nonsticky t))))

  (define-key vertico-map (kbd "S-SPC") #'+vertico-restrict-to-matches)

  ;; Enable vertico-multiform
  (vertico-multiform-mode)

  ;; Configure the display per command.
  ;; Use a buffer with indices for imenu
  ;; and a flat (Ido-like) menu for M-x.
  (setq vertico-multiform-commands
        '((consult-imenu buffer indexed)
          (consult-line (vertico-sort-override-function . vertico-sort-alpha))
          ;; Configure `consult-outline' as a scaled down TOC in a separate buffer
          (consult-outline buffer ,(lambda (_) (text-scale-set -1)))))


  ;; Configure the display per completion category.
  ;; Use the grid display for files and a buffer
  ;; for the consult-grep commands.
  (setq vertico-multiform-categories
        '((consult-grep buffer)
          (consult-find vertical)
          (symbol (vertico-sort-function . vertico-sort-alpha))))
                                                                  
  (defun my/vertico-truncate-candidates (args)
    (if-let ((arg (car args))
             (type (get-text-property 0 'multi-category arg))
             ((eq (car-safe type) 'file))
             (w (max 30 (- (window-width) 38)))
             (l (length arg))
             ((> l w)))
        (setcar args (concat "…" (truncate-string-to-width arg l (- l w)))))
    args)
  (advice-add #'vertico--format-candidate :filter-args #'my/vertico-truncate-candidates)

  (defun vertico--swap-annotations (result)
    ;; Move annotations only for files
    (if minibuffer-completing-file-name
        (mapcar (lambda (x)
                  ;; Swap prefix/suffix annotations
                  (list (car x) (concat (string-trim-left (caddr x)) " ") (cadr x)))
                result)
      result))
  (advice-add #'vertico--affixate :filter-return #'vertico--swap-annotations)

  (advice-add #'ffap-menu-ask :around
              (lambda (&rest args)
                (cl-letf (((symbol-function #'minibuffer-completion-help)
                           #'ignore))
                  (apply args)))))


;; Configure directory extension.
(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word)
              ("C-l" . vertico-directory-up))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package vertico-sort
  :after vertico
  :ensure nil)

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
