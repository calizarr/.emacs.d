;; -*- lexical-binding: t; -*-

;; Customize font for emacs

;; (set-fontset-font
;;     t (cons ? ?)
;;     (font-spec :family "DejaVu Sans Mono for Powerline"))

(if (is-windows)
    (progn
      (set-face-attribute 'default nil :font "DejaVu Sans Mono for Powerline-10")
      (set-frame-font "DejaVu Sans Mono for Powerline-10" nil t)))


(if (is-linux)
    (if (is-wsl)
        (progn
          (set-face-attribute 'default nil :font "DejaVu Sans Mono-11")
          (set-frame-font "DejaVu Sans Mono-11" nil t))
      (progn
        (set-face-attribute 'default nil :font "DejaVu Sans Mono-11")
        (set-frame-font "DejaVu Sans Mono-11" nil t))))
