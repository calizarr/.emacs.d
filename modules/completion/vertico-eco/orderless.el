;; -*- lexical-binding: t -*-

;; Optionally use the `orderless' completion style.
(use-package orderless
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless substring partial-completion flex basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion))))
  :config

  (defun +orderless--consult-suffix ()
    "Regexp which matches the end of string with Consult tofu support."
    (if (boundp 'consult--tofu-regexp)
        (concat consult--tofu-regexp "*\\'")
      "\\'"))

  ;; Recognizes the following patterns:
  ;; * .ext (file extension)
  ;; * regexp$ (regexp matching at end)
  (defun +orderless-consult-dispatch (word _index _total)
    (cond
     ;; Ensure that $ works with Consult commands, which add disambiguation suffixes
     ((string-suffix-p "$" word)
      `(orderless-regexp . ,(concat (substring word 0 -1) (+orderless--consult-suffix))))
     ;; File extensions
     ((and (or minibuffer-completing-file-name
               (derived-mode-p 'eshell-mode))
           (string-match-p "\\`\\.." word))
      `(orderless-regexp . ,(concat "\\." (substring word 1) (+orderless--consult-suffix))))))
  )

;; (use-package orderless
;;   :demand t
;;   :after consult
;;   :config

;;   ;; Define orderless style with initialism by default
;;   (orderless-define-completion-style +orderless-with-initialism
;;     (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp)))

;;   ;; Certain dynamic completion tables (completion-table-dynamic) do not work
;;   ;; properly with orderless. One can add basic as a fallback.  Basic will only
;;   ;; be used when orderless fails, which happens only for these special
;;   ;; tables. Also note that you may want to configure special styles for special
;;   ;; completion categories, e.g., partial-completion for files.
;;   (setq completon-styles '(orderless basic)
;;         completion-category-defaults nil
;;         ;;; Enable partial-completion for files.
;;         ;;; Either give orderless precedence or partial-completion.
;;         ;;; Note that completion-category-overrides is not really an override,
;;         ;;; but rather prepended to the default completion-styles.
;;         ;; completion-category-overrides '((file (styles orderless partial-completion))) ;; orderless is tried first
;;         completion-category-overrides '((file (styles partial-completion)) ;; partial-completion is tried first
;;                                         ;; enable initialism by default for symbols
;;                                         (command (styles +orderless-with-initialism))
;;                                         (variable (styles +orderless-with-initialism))
;;                                         (symbol (styles +orderless-with-initialism)))
;;         orderless-component-separator #'orderless-escapable-split-on-space ;; allow escaping space with backslash!
;;         orderless-style-dispatchers (list #'+orderless-consult-dispatch
;;                                           #'orderless-kwd-dispatch
;;                                           #'orderless-affix-dispatch)))

;; (defun consult--orderless-regexp-compiler (input type &rest _config)
;;   (setq input (cdr (orderless-compile input)))
;;   (cons
;;    (mapcar (lambda (r) (consult--convert-regexp r type)) input)
;;    (lambda (str) (orderless--highlight input t str))))

;; ;; OPTION 1: Activate globally for all consult-grep/ripgrep/find/...
;; ;; (setq consult--regexp-compiler #'consult--orderless-regexp-compiler)

;; ;; OPTION 2: Activate only for some commands, e.g., consult-ripgrep!
;; (defun consult--with-orderless (&rest args)
;;   (minibuffer-with-setup-hook
;;       (lambda ()
;;         (setq-local consult--regexp-compiler #'consult--orderless-regexp-compiler))
;;     (apply args)))
;; (advice-add #'consult-ripgrep :around #'consult--with-orderless)
