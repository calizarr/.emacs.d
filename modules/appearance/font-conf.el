;; Customize font for emacs

;; (set-fontset-font
;;     t (cons ? ?)
;;     (font-spec :family "DejaVu Sans Mono for Powerline"))

(if (is-windows)
    (progn
      (set-face-attribute 'default nil :font "DejaVu Sans Mono for Powerline-10")
      (set-frame-font "DejaVu Sans Mono for Powerline-10" nil t)))
