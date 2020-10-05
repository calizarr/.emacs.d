;; SBT-Mode package
(use-package sbt-mode
  :ensure t
  :pin melpa
  :init
  (setq
   sbt:ansi-support t
   sbt:prefer-nested-projects t)
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
  ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
  (setq sbt:program-options '("-Dsbt.supershell=false"))
  )

;; Scala-Mode package
;; Enable scala-mode and sbt-mode
(use-package scala-mode
  :interpreter
    ("scala" . scala-mode)
  :mode "\\.s\\(cala\\|sc\\|bt\\)$"
  :hook ((scala-mode . show-paren-mode)
         (scala-mode . smartparens-mode)
         (scala-mode . yas-minor-mode)
         (scala-mode . company-mode)
         (scala-mode . scala-mode:goto-start-of-code)
         )
  )

;; Adding .sc files to scala mode
;; (add-to-list 'auto-mode-alist '("\\.\\(scala\\|sc\\|sbt\\)\\'" . scala-mode))

;; TODO: Replace highlight-symbol with a different package
(use-package highlight-symbol
  :diminish highlight-symbol-mode
  :commands highlight-symbol
  :bind ("s-h" . highlight-symbol))

(use-package goto-chg
  :commands goto-last-change
  ;; complementary to
  ;; C-x r m / C-x r l
  ;; and C-<space> C-<space> / C-u C-<space>
  :bind (("C-." . goto-last-change)
         ("C-," . goto-last-change-reverse)))

(use-package popup-imenu
  :commands popup-imenu
  :bind ("M-i" . popup-imenu))

;; Smartparens settings for scala-mode
(sp-local-pair 'scala-mode "(" nil :post-handlers '(("||\n[i]" "RET")))
(sp-local-pair 'scala-mode "{" nil :post-handlers '(("||\n[i]" "RET") ("| " "SPC")))

(defun sp-restrict-c (sym)
  "Smartparens restriction on `SYM' for C-derived parenthesis."
  (sp-restrict-to-pairs-interactive "{([" sym))

(bind-key "s-{" 'sp-rewrap-sexp smartparens-mode-map)
