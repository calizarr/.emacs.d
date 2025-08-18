;;; helm-ls.el --- description -*- lexical-binding: t; -*-

;;; Commentary

;; LSP Clients for the helm-ls server

;;; Code:
(lsp-defcustom lsp-helm-language-server-property "info"
  "LogLevel"
  :group 'helm-ls
  :lsp-path "helm.logLevel")

(lsp-defcustom lsp-helm-language-server-property "values.yaml"
  "valuesFiles"
  :group 'helm-ls
  :lsp-path "helm.valuesFiles.mainValuesFile")

(lsp-defcustom lsp-helm-language-server-property "values.lint.yaml"
  "Lint values file"
  :group 'helm-ls
  :lsp-path "helm.valuesFiles.lintOverlayValuesFile")

(lsp-defcustom lsp-helm-language-server-property "values*.yaml"
  "Additional values file"
  :group 'helm-ls
  :lsp-path "helm.valuesFiles.additionavaluesFilesGlobPattern")

(lsp-defcustom lsp-helm-language-server-property "true"
  "Enable helm lint"
  :group 'helm-ls
  :lsp-path "helm.helmLint.enabled")

(lsp-defcustom lsp-helm-language-server-property (makehash :test 'eql)
  "Ignored messages"
  :group 'helm-ls
  :lsp-path "helm.helmLint.ignoredMessages")

(lsp-defcustom lsp-helm-language-server-property "true"
  "Enabled YLSP"
  :group 'helm-ls
  :lsp-path "helm.yamlls.enabled")

(lsp-defcustom lsp-helm-language-server-property "*.{yaml,yml}"
  "Glob Files Enabled"
  :group 'helm-ls
  :lsp-path "helm.yamlls.enabledForFilesGlob")

(lsp-defcustom lsp-helm-language-server-property 50
  "Diagnostics Limit"
  :group 'helm-ls
  :lsp-path "helm.yamlls.diagnosticsLimit")

(lsp-defcustom lsp-helm-language-server-property "false"
  "Show Diagnostics Directly"
  :group 'helm-ls
  :lsp-path "helm.yamlls.showDiagnosticsDirectly")

(lsp-defcustom lsp-helm-language-server-property "yaml-language-server"
  "YLSP Path"
  :group 'helm-ls
  :lsp-path "helm.yamlls.path")

(lsp-defcustom lsp-helm-language-server-property 3
  "Initialization Timeout"
  :group 'helm-ls
  :lsp-path "helm.yamlls.initTimeoutSeconds")

(lsp-defcustom lsp-helm-language-server-property "templates/**"
  "Kubernetes Schemas Directory?"
  :group 'helm-ls
  :lsp-path "helm.yamlls.config.schemas.kubernetes")

(lsp-defcustom lsp-helm-language-server-property "true"
  "YLSP Completion"
  :group 'helm-ls
  :lsp-path "helm.yamlls.config.completion")

(lsp-defcustom lsp-helm-language-server-property "true"
  "Enable hover"
  :group 'helm-ls
  :lsp-path "helm.yamlls.config.hover")
