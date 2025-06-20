;; -*- lexical-binding: t; -*-

;; URL: https://github.com/mickeynp/combobulate

(setq combobulate-home (concat (getenv "GITHUB_REPOS") "/" "combobulate"))

(if (file-directory-p combobulate-home)
    (use-package combobulate
      :custom
      ;; You can customize Combobulate's key prefix here.
      ;; Note that you may have to restart Emacs for this to take effect!
      (combobulate-key-prefix "C-c o")
      :hook ((prog-mode . combobulate-mode))
      ;; Amend this to the directory where you keep Combobulate's source
      ;; code.
      :load-path combobulate-home)
  (display-warning 'combobulate (concat "Combobulate directory does not exist, please clone: https://github.com/mickeynp/combobulate to " (getenv "GITHUB_REPOS")) :warning))
