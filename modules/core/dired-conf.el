;; -*- lexical-binding: t; -*-

(put 'dired-find-alternate-file 'disabled nil)

(use-package dired
  :ensure nil
  :config
  (progn
    (defun mydired-sort ()
      "Sort dired listings with directories first."
      (save-excursion
        (let (buffer-read-only)
          (forward-line 2) ;; beyond dir. header
          (sort-regexp-fields t "^.*$" "[ ]*." (point) (point-max)))
        (set-buffer-modified-p nil)))

    (defadvice dired-readin
        (after dired-after-updating-hook first () activate)
      "Sort dired listings with directories first before adding marks."
      (mydired-sort)))
  :custom
  ;; Dired Mode Settings
  (wdired-allow-change-permissions t)
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always)
  (dired-dwim-target t)
  (dired-listing-switches "-alh"))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

;; Expand subtrees inline using TAB
(use-package dired-subtree
  :after dired
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle)
              ("<backtab>" . dired-subtree-cycle)
              ("M-<down>" . dired-subtree-insert)
              ("M-<up>" . dired-subtree-remove)))

;; When a dir has only one child, show it inline -- nice.
(use-package dired-collapse
  :after dired
  :config
  (global-dired-collapse-mode))

(use-package dired-filter
  :after dired
  :bind (:map dired-mode-map
              ;; Open filter menu
              ("/" . dired-filter-map)
              ;; Quickly clear filters ("/ /" also works))
              ("C-/" . dired-filter-pop-all)))

(add-hook 'dired-load-hook
          (lambda ()
            (load "dired-x")
            ;; Set dired-x global variables here.  For example:
            ;; (setq dired-guess-shell-gnutar "gtar")
            ;; (setq dired-x-hands-off-my-keys nil)
            ))
;; (add-hook 'dired-mode-hook
;;           (lambda ()
;;             ;; Set dired-x buffer-local variables here.  For example:
;;             ;; (dired-omit-mode 1)
;;             (treemacs-icons-dired-mode 1)
;;             ))
