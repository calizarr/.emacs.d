;; -*- lexical-binding: t; -*-

(use-package corfu
  :ensure t
  ;; Optional customizations
  :custom
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  (corfu-auto t)
  (corfu-auto-delay 0.10)
  ;; (corfu-quit-no-match t)

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  :init
  ;; Recommended: Enable Corfu globally.  Recommended since many modes provide
  ;; Capfs and Dabbrev can be used globally (M-/).  See also the customization
  ;; variable `global-corfu-modes' to exclude certain modes.
  (global-corfu-mode)
  ;; Enable optional extension modes:
  (corfu-history-mode)
  (corfu-popupinfo-mode)
  (corfu-echo-mode)
  )

;; Add extensions
(use-package cape
  :demand t
  ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
  ;; Press C-c c ? to for help.
  :bind ("C-c c" . cape-prefix-map) ;; Alternative key: M-<tab>, M-p, M-+
  ;; Alternatively bind Cape commands individually.
  ;; :bind (("C-c p d" . cape-dabbrev)
  ;;        ("C-c p h" . cape-history)
  ;;        ("C-c p f" . cape-file)
  ;;        ...)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-abbrev)
  (add-hook 'completion-at-point-functions #'cape-keyword)
  (add-hook 'completion-at-point-functions #'cape-history)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  (add-hook 'completion-at-point-functions #'cape-elisp-symbol)
  (add-hook 'completion-at-point-functions #'cape-dict)
  (add-hook 'completion-at-point-functions #'cape-emoji)
  (add-hook 'completion-at-point-functions #'cape-line)
  (add-hook 'completion-at-point-functions #'cape-rfc1345)
  (add-hook 'completion-at-point-functions #'cape-sgml)
  (add-hook 'completion-at-point-functions #'cape-tex)
  (message (format "Loading my capf extensions: %s" completion-at-point-functions))
  ;; ...
  :config
  (defun my/ignore-elisp-keywords (cand)
    (or (not (keywordp cand))
        (eq (char-after (car completion-in-region--data)) ?:)))

  (defun my/setup-elisp ()
    (setq-local completion-at-point-functions
                `(,(cape-capf-super
                    (cape-capf-predicate
                     #'elisp-completion-at-point
                     #'my/ignore-elisp-keywords)
                    #'cape-dabbrev)
                  cape-file)
                cape-dabbrev-min-length 5))
  (add-hook 'emacs-lisp-mode-hook #'my/setup-elisp))

;; Nice icons for corfu popups
(use-package kind-icon
  :after corfu
  :demand t
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; Use Dabbrev with Corfu!
(use-package dabbrev
  ;; Swap M-/ and C-M-/
  :bind (("M-/" . dabbrev-completion)
         ("C-M-/" . dabbrev-expand))
  :config
  ;; (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  ;; Available since Emacs 29 (Use `dabbrev-ignored-buffer-regexps' on older Emacs)
  (add-to-list 'dabbrev-ignored-buffer-modes 'authinfo-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
  (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))
