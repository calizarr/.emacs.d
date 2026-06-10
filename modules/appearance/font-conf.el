;; -*- lexical-binding: t; -*-

;; Customize font for emacs

;; (set-fontset-font
;;     t (cons ? ?)
;;     (font-spec :family "DejaVu Sans Mono for Powerline"))

(cond
 ;; 🍏 macOS Configuration (Handles Both Personal & Work MacBooks)
 ((is-mac)
  (let* ((hostname (system-name))
         (font-size (cond
                     ;; Work M4 MacBook Pro Maxed Out Resolution
                     ((string-match-p "Cesar" hostname) 16)
                     
                     ;; Personal 2019 Intel 16-inch MacBook Pro
                     ((string-match-p "Remote" hostname) 14)
                     
                     ;; General Mac fallback size
                     (t 15)))
         (font-string (format "Menlo-%d" font-size)))
    
    ;; Set the font globally
    (add-to-list 'initial-frame-alist `(font . ,font-string))
    (add-to-list 'default-frame-alist `(font . ,font-string))
    (set-frame-font font-string nil t)

    ;; 🖼️ Custom Padding for Rectangle Window Borders
    ;; Adds breathability so text does not clip against screen edges
    (add-to-list 'default-frame-alist '(internal-border-width . 12))
    (add-to-list 'initial-frame-alist '(internal-border-width . 12))))

 ;; 🪟 Windows Configuration
 ((is-windows)
  (let* ((font-string "DejaVu Sans Mono for Powerline-10"))
    (set-face-attribute 'default nil :font font-string)
    (set-frame-font font-string nil t)))

 ;; 🐧 Linux / WSL Configuration
 ((is-linux)
  (let* ((font-string "DejaVu Sans Mono-11"))
    (set-face-attribute 'default nil :font font-string)
    (set-frame-font font-string nil t))))

;; ⌨️ Global Keybindings to Cycle Font Sizing
;; Fast, temporary adjustments using standard Mac Cmd keys
(global-set-key (kbd "S-s-=") 'text-scale-increase) ; Cmd + Plus Sign
(global-set-key (kbd "s--") 'text-scale-decrease) ; Cmd + Minus Sign
(global-set-key (kbd "s-0") 'text-scale-adjust)   ; Cmd + Zero resets
