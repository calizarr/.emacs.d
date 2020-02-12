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

;; Pandoc Mode
(use-package pandoc-mode
  :ensure t
  :config
  (add-hook 'markdown-mode-hook 'pandoc-mode))

;; Add powershell-mode
(use-package powershell
  :ensure t)
