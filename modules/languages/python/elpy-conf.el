;; Elpy-Install information
(use-package elpy
  :ensure t
  :commands elpy-enable
  :after python
  :config (elpy-enable)
  :init (with-eval-after-load 'python (elpy-enable))
  )

(elpy-enable)

(setq elpy-shell-use-project-root nil)

;; (require package)
;; (add-to-list 'package-archives
;;              '("elpy" . "https://jorgenschaefer.github.io/packages/"))

;; (package-initialize)
