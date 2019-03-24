;; Get a general yaml-mode that does not exist in emacs proper
(use-package yaml-mode)

;; Markdown Mode
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command (concat
                                "/usr/local/bin/pandoc"
                                " --from=markdown --to=html"
                                " --standalone --mathjax --highlight-style=pygments")))
;; Pandoc Mode
(use-package pandoc-mode
  :ensure t
  :config
  (add-hook 'markdown-mode-hook 'pandoc-mode)
  (add-hook 'pandoc-mode-hook 'pandoc-load-default-settings))

;; Add powershell-mode
(use-package powershell
  :ensure t)
