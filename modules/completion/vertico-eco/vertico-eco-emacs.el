;; -*- lexical-binding: t; -*-

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))

  ;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
  ;; to switch display modes.
  (setq context-menu-mode t
        ;; Support opening new minibuffers from inside existing minibuffers.
        enable-recursive-minibuffers t
        ;; Hide commands in M-x which do not work in the current mode.  Vertico
        ;; commands are hidden in normal buffers. This setting is useful beyond
        ;; Vertico.
        read-extended-command-predicate #'command-completion-default-include-p
        ;; TAB cycle if there are only few candidates
        completion-cycle-threshold 3
        ;; Enable indentation+completion using the TAB key.
        ;; `completion-at-point' is often bound to M-TAB.
        tab-always-indent 'complete
        ;; Emacs 30 and newer: Disable Ispell completion function.
        ;; Try `cape-dict' as an alternative.
        text-mode-ispell-word-completion nil
        ;; Hide commands in M-x which do not apply to the current mode.  Corfu
        ;; commands are hidden, since they are not used via M-x. This setting is
        ;; useful beyond Corfu.
        read-extended-command-predicate #'command-completion-default-include-p))
