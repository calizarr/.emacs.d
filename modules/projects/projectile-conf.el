;; -*- lexical-binding: t; -*-

;; Projectile Configurations
(use-package projectile
  :demand
  :ensure t
  :init (setq projectile-use-git-grep t
              ;; Opens project root when using projectile-switch-project (C-c p p)
              projectile-switch-project-action #'projectile-dired)
  :bind (("s-f" . projectile-find-file))
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;; (defun projectile-discover-projects-in-directory (directory)
;;   "Discover any projects in DIRECTORY and add them to the projectile cache.
;; This function is not recursive and only adds projects with roots
;; at the top level of DIRECTORY."
;;   (interactive
;;    (list (read-directory-name "Starting directory: ")))
;;   (let ((subdirs (directory-files directory t)))
;;     (mapcar
;;      (lambda (dir)
;;        (when (and (file-directory-p dir)
;;                   (not (member (file-name-nondirectory dir) '(".." "."))))
;;          (let ((default-directory dir)
;;                (projectile-cached-project-root dir))
;;            (when (projectile-project-p)
;;              (projectile-add-known-project (projectile-project-root))))))
;;      subdirs)))

;; Needed to use `.projectile` ignores or the globally ignored section above
(defun projectile-setup-indexing ()
  "Check for not windows and then set projectile-indexing appropriately."
  ;; Linux/OSX can use hybrid to ignore certain files and enable-caching
  (if (not-windows)
      (progn
        (setq projectile-indexing-method 'hybrid
              projectile-enable-caching t)
        (message
         (format "Projectile indexing is now: %s and caching is: %s" projectile-indexing-method projectile-enable-caching)))
    ;; If Windows has fd and tr, use them
    (if (and (is-windows) (locate-file "fd" exec-path exec-suffixes 1) (locate-file "tr" exec-path exec-suffixes 1))
        (progn
          (setq projectile-indexing-method 'alien
                projectile-enable-caching t
                projectile-git-command "fd . -0 --type f --color=never"
                projectile-generic-command "fd . -0 --type f --color=never")
          (message
           (format "Projectile indexing is now: %s and caching is: %s" projectile-indexing-method projectile-enable-caching))
          (message "fd is being used for git and generic commands"))
      ;; If it doesn't use the painfully slow native indexing
      (setq projectile-indexing-method 'native
            projectile-enable-caching t))))

(projectile-setup-indexing)

(push "*.mypy_cache" projectile-globally-ignored-directories)
(push "*.tree-sitter" projectile-globally-ignored-directories)
(push "*.bloop" projectile-globally-ignored-directories)
