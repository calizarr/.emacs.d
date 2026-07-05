;; -*- lexical-binding: t; -*-

;;  -- Miscellaneous llm configs for emacs 
;;

;; Works with ai-code-interface.el
(use-package gptel
  :vc (:url "https://github.com/karthink/gptel" :rev :newest))

;; Integrates with gptel
;; https://github.com/lizqwerscott/mcp.el
(use-package mcp
  :ensure t
  :after gptel
  ;; :hook (after-init . mcp-hub-start-all-server)
  :config (require 'mcp-hub))

;; https://github.com/lizqwerscott/gptel-mcp.el
(use-package gptel-mcp
  :ensure t
  ;; :bind (:map gptel-mode-map
  ;;             ("C-c m" . gptel-mcp-dispatch))
  :vc (:url "https://github.com/lizqwerscott/gptel-mcp.el"))

;; Required by agent-shell
;; https://github.com/xenodium/acp.el
(use-package acp
  :vc (:url "https://github.com/xenodium/acp.el" :rev :newest))

;; Agent Shell
;; https://github.com/xenodium/agent-shell
;; Needs: https://github.com/agentclientprotocol/claude-agent-acp
;; Command: npm install -g @agentclientprotocol/claude-agent-acp
;; Claude emacs skills: https://github.com/xenodium/emacs-skills (via agent-shell but should work on any method)
(use-package agent-shell
    :ensure t
    ;; :ensure-system-package
    ;; ;; Add agent installation configs here
    ;; ((claude . "brew install claude-code")
    ;;  (claude-agent-acp . "npm install -g @agentclientprotocol/claude-agent-acp"))
    )

;; llm-conf.el ends here
