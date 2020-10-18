;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;; (package-initialize)
;; (require 'package)

;; Set this first to speed up startup 5.5s -> 2.5s
(setq gc-cons-threshold (expt 2 24)) ;; 16mb instead of 800k

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-for-comint-mode t)
 '(ansi-color-names-vector
   ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
 '(custom-enabled-themes '(tango-dark))
 '(custom-safe-themes
   '("3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "b9e9ba5aeedcc5ba8be99f1cc9301f6679912910ff92fdf7980929c2fc83ab4d" "84d2f9eeb3f82d619ca4bfffe5f157282f4779732f48a5ac1484d94d5ff5b279" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" default))
 '(desktop-save-mode nil)
 '(dired-listing-switches "-alh")
 '(display-line-numbers t)
 '(ediff-window-setup-function 'ediff-setup-windows-plain)
 '(eide-custom-color-theme 'dark)
 '(package-selected-packages
   '(helm-ag helm-xref helm-swoop ensime perspective loop helm-company conda helm-rg helm-fd helm-projectile helm-lsp kubernetes kubel k8s-mode sbt-mode pyenv-mode json-navigator ahk-mode lsp-metals lsp-treemacs which-key grip-mode company-terraform terraform-mode go-mode poly-ansible company-ansible ansible-doc ansible pretty-hydra htmlize groovy-mode company-anaconda protobuf-mode smart-mode-line lsp-mode scala-mode markdown-mode lsp-ui powershell elisp-lint pandoc-mode yaml-mode highlight-indent-guides flycheck js2-mode rainbow-mode web-mode tide prodigy know-your-http-well company page-break-lines pyenv-mode-auto sphinx-doc sphinx-mode request restclient-helm auto-yasnippet helpful eshell-mode smex company-restclient restclient nyan-mode ido-grid-mode pcre2el f dockerfile-mode calfw vlf yasnippet-snippets dashboard company-quickhelp company-jedi ido-yes-or-no ido-vertical-mode ido-completing-read+ auto-complete neotree e2wm e2wm-R persp-projectile zoom pretty-mode elscreen doremi stan-mode dirtree fish-mode eimp dired+ expand-region smartparens popup-imenu goto-chg highlight-symbol flx-ido undo-tree projectile elpy csv-mode use-package exec-path-from-shell yafolding treemacs-projectile treemacs-magit treemacs-icons-dired smart-mode-line-powerline-theme powerline beacon))
 '(pop-up-frames nil)
 '(undo-outer-limit 999999999999999))


(defvar cal-modules
  (concat user-emacs-directory
          (convert-standard-filename "modules/"))
  "Directory containing personal settings in a modular format.")

;; Custom built / Stack Overflow Etc Settings
(add-to-list 'load-path cal-modules)
(let ((default-directory cal-modules))
  (normal-top-level-add-subdirs-to-load-path))

;; Charlie Settings For Below
;; Load Individual Modules
(require 'core-init)
(require 'appearance-init)
(require 'completion-init)
(require 'projects-init)
(require 'lsp-init)
(require 'python-init)
(require 'scala-init)
(require 'frontend-init)
(require 'elisp-init)
(require 'http-init)
(require 'infra-init)
(require 'go-init)


;;;
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
