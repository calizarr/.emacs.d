;; Make sure you have highlight-indentation-guides
(use-package highlight-indent-guides
  :ensure t
  :config
  (setq
   highlight-indent-guides-responsive 'top)
  )

;; Get a general yaml-mode that does not exist in emacs proper
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

;; (use-package origami
;;   :ensure t
;;   :bind (:map origami-mode-map ("C-c C-f" . hydra-origami/body))
;; )

;; (defhydra hydra-origami (:color red :hint nil :exit t)
;;   "
;;           ^Origami Mode!^
;; ------------------------------------------------------------------
;; [_o_] open node    [_n_] next fold       [_f_] toggle forward node
;; [_c_] close node   [_p_] previous fold   [_a_] toggle all nodes
;; [_u_] undo fold    [_r_] redo fold       [_x_] origami reset
;; [_s_] show node    [_l_] show only node  
;;   "
;;   ("o" origami-open-node)
;;   ("c" origami-close-node)
;;   ("n" origami-next-fold)
;;   ("p" origami-previous-fold)
;;   ("f" origami-forward-toggle-node)
;;   ("a" origami-toggle-all-nodes)
;;   ("u" origami-undo)
;;   ("r" origami-redo)
;;   ("x" origami-reset)
;;   ("s" origami-show-node)
;;   ("l" origami-show-only-node)
;;   )

(use-package yafolding
  :ensure t)

(defvar yafolding-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "<C-S-return>") #'yafolding-hide-parent-element)
    (define-key map (kbd "<C-M-return>") #'yafolding-toggle-all)
    (define-key map (kbd "<C-return>") #'yafolding-toggle-element)
    map))
