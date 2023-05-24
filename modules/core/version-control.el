;;; Version Control Settings such as magit etc.

(if (is-mac)
    ;; (setq git-commit-post-finish-hook #'((lambda () (shell-command (string-join `("cd" ,(getenv "PWD") "&&" "git commit --amend --no-edit" "-S",(getenv "GPG_DEFAULT_KEY")) " "))))))
    (setq git-commit-post-finish-hook #'((lambda () (shell-command ((string-join `("cd" ,(getenv "PWD") "&&" "git commit --amend --no-edit" ,(string-join `("-S" ,(getenv "GPG_DEFAULT_KEY")))) " ")))))))

(use-package magit
  :ensure t
  :pin melpa
  :bind (("C-x g" . #'magit-status))
  )


(use-package forge
  :ensure t
  :pin melpa
  :after magit
  )

;; Enable loopback so that pinentry will pop up in emacs
;; (setq epa-pinentry-mode 'ask)
;; (pinentry-start)

;; (use-package epg
;;   :init
;;   (setq epg-pinentry-mode 'loopback
;;         epg-debug t))
