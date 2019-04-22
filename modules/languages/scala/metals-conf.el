;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :init (global-flycheck-mode))

(use-package lsp-mode
  :ensure
  :pin melpa
  :init (setq lsp-prefer-flymake nil))

(use-package lsp-ui
  :ensure
  :pin melpa
  :hook (lsp-mode . lsp-ui-mode))

(use-package helm-lsp
  :ensure t)

(use-package lsp-scala
  :after scala-mode
  :demand t
  ;; Optional - enable lsp-scala automatically in scala files
  :hook (scala-mode . lsp)
  )

(use-package company-lsp
  :ensure t)
(push 'company-lsp company-backends)

;; Printing server I/O for debugging
;; (setq 'lsp-print-io t)

