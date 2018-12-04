;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;; (package-initialize)
;; (require 'package)

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
 '(custom-enabled-themes (quote (tango-dark)))
 '(desktop-save-mode nil)
 '(dired-listing-switches "-alh")
 '(display-line-numbers t)
 '(ediff-window-setup-function (quote ediff-setup-windows-plain))
 '(eide-custom-color-theme (quote dark))
 '(ensime-sbt-command "nil")
 '(ensime-startup-notification nil)
 '(ido-grid-mode t)
 '(ido-vertical-mode t)
 '(package-selected-packages
   (quote
    (pyenv-mode pyenv-mode-auto sphinx-doc sphinx-mode helm-company beacon request restclient-helm auto-yasnippet helm-projectile helm helpful eshell-mode smex company-restclient restclient nyan-mode ido-grid-mode pcre2el f dockerfile-mode calfw vlf magit yasnippet-snippets dashboard company-quickhelp company-jedi ido-yes-or-no ido-vertical-mode ido-completing-read+ auto-complete neotree e2wm e2wm-R persp-projectile zoom pretty-mode elscreen doremi stan-mode dirtree fish-mode eimp dired+ expand-region smartparens popup-imenu goto-chg highlight-symbol flx-ido undo-tree projectile ensime elpy csv-mode use-package exec-path-from-shell)))
 '(pop-up-frames nil)
 '(sbt:ansi-support t)
 '(sbt:prefer-nested-projects t)
 '(undo-outer-limit 999999999999999))

;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(company-quickhelp-color-background ((t (:background "#454e51"))))
;;  '(company-quickhelp-color-foreground ((t (:background "#394143"))))
;;  '(company-scrollbar-bg ((t (:background "#ffffffffffff"))))
;;  '(company-scrollbar-fg ((t (:background "#ffffffffffff"))))
;;  '(company-tooltip ((t (:inherit default :background "#ffffffffffff"))))
;;  '(company-tooltip-common ((t (:inherit font-lock-constant-face))))
;;  '(company-tooltip-selection ((t (:inherit font-lock-function-name-face)))))


;; Custom built / Stack Overflow Etc Settings
(add-to-list 'load-path "~/.emacs.d/modules")
(add-to-list 'load-path "~/.emacs.d/modules/core")
(add-to-list 'load-path "~/.emacs.d/modules/appearance")
(add-to-list 'load-path "~/.emacs.d/modules/completion")
(add-to-list 'load-path "~/.emacs.d/modules/languages")
(add-to-list 'load-path "~/.emacs.d/modules/languages/python")
(add-to-list 'load-path "~/.emacs.d/modules/languages/scala")
(add-to-list 'load-path "~/.emacs.d/modules/projects")
(add-to-list 'load-path "~/.emacs.d/modules/http")

;; Load Individual Modules
(load "core/core-init")
(load "appearance/appearance-init")
(load "completion/completion-init")
(load "python/python-init")
(load "scala/scala-init")
(load "projects/projects-init")
(load "http/http-init")

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-scrollbar-bg ((t (:background "#45bb4ed351db"))))
 '(company-scrollbar-fg ((t (:background "#39f441834408"))))
 '(company-tooltip ((t (:inherit default :background "#32e339873bbd"))))
 '(company-tooltip-common ((t (:inherit font-lock-constant-face))))
 '(company-tooltip-selection ((t (:inherit font-lock-function-name-face)))))
