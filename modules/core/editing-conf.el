;; -*- lexical-binding: t; -*-

;; Make sure you have highlight-indentation-guides
(use-package highlight-indent-guides
  :ensure t
  :config
  (setq
   highlight-indent-guides-responsive nil)
  )

;; Get a general yaml-mode that does not exist in emacs proper
(use-package yafolding
  :ensure t)

(defvar yafolding-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<C-S-return>") #'yafolding-hide-parent-element)
    (define-key map (kbd "<C-M-return>") #'yafolding-toggle-all)
    (define-key map (kbd "<C-return>") #'yafolding-toggle-element)
    map))

(use-package yaml-mode
  :ensure t
  :hook (yaml-mode . yafolding-mode)
  )

(add-hook 'yaml-mode-hook 'highlight-indent-guides-mode)

;; Markdown Mode
(use-package markdown-mode
  :ensure t
  :pin melpa
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  ;; :init (setq markdown-command (concat
  ;;                               "/usr/local/bin/pandoc"
  ;;                               " --from=markdown --to=html"
  ;;                               " --standalone --mathjax --highlight-style=pygments"))
  )

;; grip-mode (GitHub Flavored Markdown)
;; https://github.com/seagle0128/grip-mode
(use-package grip-mode
  :ensure t)

;; Pandoc Mode
(use-package pandoc-mode
  :ensure t
  :config
  (add-hook 'markdown-mode-hook 'pandoc-mode))

;; TODO: Add json parsing modes / navigators etc.


;; Add powershell-mode
(use-package powershell
  :ensure t)

;;; Ediff: split horizontally (A|B, like C-x 3) and
;;; don't use the little floating control frame.
(use-package ediff
  :ensure nil
  :config
  (setq ediff-split-window-function 'split-window-horizontally)
  (setq ediff-window-setup-function 'ediff-setup-windows-plain))

;;; Temporarily highlight undo, yank, find-tag and a few other things
(use-package volatile-highlights
  :config
  (volatile-highlights-mode t)
  :diminish volatile-highlights-mode)

(use-package all-the-icons)

;; better visual paren matching
(use-package mic-paren
  :hook ((c-mode-common .
                        (lambda ()
                          (paren-toggle-open-paren-context 1)))
         (c-ts-base-mode .
                         (lambda ()
                           (paren-toggle-open-paren-context 1))))
  :config
  (paren-activate))

(use-package smartparens
  :diminish smartparens-mode
  :commands
  smartparens-strict-mode
  smartparens-mode
  sp-restrict-to-pairs-interactive
  sp-local-pair
  :init
  (setq sp-interactive-dwim t)
  :bind (:map smartparens-mode-map
              ("M-<right>" . #'sp-backward-slurp-sexp)
              ("C-<right>" . #'sp-forward-slurp-sexp)
              ("M-<left>" . #'sp-backward-barf-sexp)
              ("C-<left>" . #'sp-forward-barf-sexp)
              )
  :config
  (require 'smartparens-config)
  (sp-use-smartparens-bindings)

  (sp-pair "(" ")" :wrap "C-(") ;; how do people live without this?
  (sp-pair "[" "]" :wrap "s-[") ;; C-[ sends ESC
  (sp-pair "{" "}" :wrap "C-{")

  (bind-key "s-<delete>" 'sp-kill-sexp smartparens-mode-map)
  (bind-key "s-<backspace>" 'sp-backward-kill-sexp smartparens-mode-map))

;;; Useful for folding, manipulating and navigating indented languages like yaml
;;; (or even python)
(use-package indent-tools
  :bind (("C-c >" . 'indent-tools-hydra/body)))

(use-package package-lint)

;; (use-package rg
;;   :ensure t)

;; (use-package ripgrep
;;   :ensure t)

(use-package deadgrep
  :config
  :bind ("C-c s" . deadgrep))

;;; wgrep-change-to-wgrep-mode to edit right in a grep buffer (or ag/ripgrep)
;;; Use C-c C-e to apply.
(use-package wgrep
  :commands wgrep-change-to-wgrep-mode
  :config
  (setq wgrep-auto-save-buffer t)
  )

;; deadgrep + wgrep
(use-package wgrep-deadgrep
  :after deadgrep wgrep)

;; Giving Windows (Hyper, Alt, and Super) keys
;; See: https://stackoverflow.com/questions/27418756/is-it-possible-to-make-emacs-interpet-an-fn-key-as-a-modifier-key/27419718#27419718
;; See: C-x @ C-h
;; See: C-h i g (elisp) Translation Keymaps RET
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Windows-Keyboard.html#fn-1
(if (is-windows)
    (progn
      (define-key local-function-key-map (kbd "<f13>") 'event-apply-super-modifier)
      (define-key local-function-key-map (kbd "<f14>") 'event-apply-hyper-modifier)
      (define-key local-function-key-map (kbd "<f15>") 'event-apply-alt-modifier)
      (setq w32-lwindow-modifier 'super)
      (setq w32-rwindow-modifier nil)
      (w32-register-hot-key [s-])
      (setq w32-apps-modifier 'hyper)))

;; Autohotkey Mode
(if (is-windows)
    (use-package ahk-mode
      :ensure t
      :pin melpa-stable
      :config (setq ahk-indentation 2)))
