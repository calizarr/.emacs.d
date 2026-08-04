;; -*- lexical-binding: t; -*-

;;; Shell and Eshell settings etc.

;; Remove shell command echo
(defun my-comint-init ()
  (setq comint-process-echoes t))
(add-hook 'shell-mode-hook 'my-comint-init)

;; (setq ansi-color-faces-vector
;;       [default default default italic underline success warning error]
;;       ansi-color-for-comint-mode t
;;       ansi-color-names-vector
;;       ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])

(use-package eat
  :ensure t
  ;; Required for NonGNU ELPA if not using :vc install:
  ;; (add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
  ;; C-z in an eat buffer is forwarded to the child as SIGTSTP, which
  ;; job-control-suspends it (e.g. backgrounds an interactive `claude' session).
  ;; It is bound in eat's semi-char/char *minor-mode* maps (to `eat-self-input'),
  ;; so a buffer-local `local-set-key' can't shadow it -- rebind it in the maps
  ;; themselves. To send a literal C-z anyway, use `C-q C-z' in semi-char mode.
  :bind (:map eat-semi-char-mode-map
         ("C-z" . ignore)
         :map eat-char-mode-map
         ("C-z" . ignore)))

;; (use-package ghostel
;;   :ensure t
;;   :bind (("C-x m" . ghostel)
;;          :map ghostel-semi-char-mode-map
;;          ("C-s"  . consult-line)
;;          ("C-k"  . my/ghostel-send-C-k-and-kill)
;;          ;; ;; I'm used to go up/down the shell history with M-n/p from eshell
;;          ;; ;; Simulate this behavior in ghostel by sending C-p and C-n
;;          ;; ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl")))
;;          ;; ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl")))
;;          :map project-prefix-map
;;          ("m" . ghostel-project)
;;          ("M" . ghostel-project-list-buffers))
;;   :config
;;   (defun my/ghostel-send-C-k-and-kill ()
;;     "Send `C-k' to ghostel.
;; Like normal Emacs `C-k'.  Kill to end of line and put content in kill-ring."
;;     (interactive)
;;     (kill-ring-save (point) (line-end-position))
;;     (ghostel-send-key "k" "ctrl"))

;;   (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
;;   (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t)
;;   (add-to-list 'ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer)))

;; (use-package ghostel-compile
;;   :hook (after-init . ghostel-compile-global-mode))

;; (use-package ghostel-comint
;;   :hook (after-init . ghostel-comint-global-mode))

;; Or: vterm (comment out eat above and uncomment this)
;; (use-package vterm
;;   :ensure t
;;   )
