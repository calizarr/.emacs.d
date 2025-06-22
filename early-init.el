;;; early-init.el --- Emacs early init -*- lexical-binding: t; -*-

;;; Commentary:

;; Emacs 27 introduced early-init.el, which is run before init.el, before
;; package and UI initialization happens.

;;; Code:

;; Speed up lsp-mode w/ lsp-booster etc.
(setenv "LSP_USE_PLISTS" "true")

;; Set this first to speed up startup 5.5s -> 2.5s
(setq gc-cons-threshold most-positive-fixnum) ;; 200 MB of RAM
(setq read-process-output-max (* 1024 1024)) ;; 1mb
;; (setq comp-deferred-compilation t)

;; If an `.el' file is newer than its corresponding `.elc', load the `.el'.
(setq load-prefer-newer t)

;; Resizing the Emacs frame can be an expensive part of changing the
;; font. Inhibit this to reduce startup times with fonts that are
;; larger than the system default.
(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise t)

(provide 'early-init)

;;; early-init.el ends here
