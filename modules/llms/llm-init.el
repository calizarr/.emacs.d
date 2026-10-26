;; -*- lexical-binding: t; -*-

;;; llm-init --- Provides settings and libraries for using LLMs in Emacs
;;; Commentary:

;;; Code:

;; LLMs!
(load "claude-code-packages.el")
;; Avoid the installed package with the same filename on load-path.
(load (expand-file-name "modules/llms/codex.el" user-emacs-directory))
(load "ai-code-interface.el")

;; (load "aider.el")

(provide 'llm-init)

;;; llm-init ends here
