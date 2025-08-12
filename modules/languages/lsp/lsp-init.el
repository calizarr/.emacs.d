;;; -*- lexical-binding: t -*-
;;; lsp-init --- Provides settings for Emacs LSP mode and which key
;;; Commentary:

;;; Code:
;; LSP-mode settings for general lsp usage
(load "./lsp-conf.el")
;; Boost LSP!
;; (load "./lsp-booster.el")
;; Yaml LSP Server functions and settings
(load "./ylsp-conf.el")
;; Tree-Sitter Config
(load "./tree-sitter.el")

(provide 'lsp-init)
;;; lsp-init ends here
