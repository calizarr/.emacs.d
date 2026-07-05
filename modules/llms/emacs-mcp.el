;; -*- lexical-binding: t; -*-

;; emacs-mcp.el -- use-package config for emacs mcp server
;;
;; https://github.com/rhblind/emacs-mcp-server
;;
;;

(use-package emacs-mcp-server
  :vc (:url "https://github.com/rhblind/emacs-mcp-server" :rev :newest)
  :config
  ;; Adding the tools directory
  (add-to-list 'load-path (expand-file-name "tools" emacs-mcp-server-directory))
  (add-hook 'emacs-startup-hook #'mcp-server-start-unix))
