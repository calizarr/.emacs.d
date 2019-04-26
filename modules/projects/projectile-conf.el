;; Projectile Configurations
(use-package projectile
  :demand
  :init (setq projectile-use-git-grep t)
  :config (projectile-mode)
  :bind (("s-f" . projectile-find-file)
         ("s-F" . projectile-grep)))

(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)


(defun projectile-discover-projects-in-directory (directory)
  "Discover any projects in DIRECTORY and add them to the projectile cache.
This function is not recursive and only adds projects with roots
at the top level of DIRECTORY."
  (interactive
   (list (read-directory-name "Starting directory: ")))
  (let ((subdirs (directory-files directory t)))
    (mapcar
     (lambda (dir)
       (when (and (file-directory-p dir)
                  (not (member (file-name-nondirectory dir) '(".." "."))))
         (let ((default-directory dir)
               (projectile-cached-project-root dir))
           (when (projectile-project-p)
             (projectile-add-known-project (projectile-project-root))))))
     subdirs)))



(use-package helm-projectile
  :demand
  :ensure t
  :config (helm-projectile-on)
  )

;; Needed to use `.projectile` ignores or the globally ignored section above
(defun projectile-setup-indexing ()
  (if (not-windows)
      (setq projectile-indexing-method 'hybrid
            projectile-enable-caching t))
  ;; TODO: Add check for "tr" in path and "fd" in path else use native*
  (setq projectile-indexing-method 'alien
        projectile-enable-caching nil
        projectile-git-command "fd . -0 --color never"
        projectile-generic-command "fd . -0 --color never"
        ))

(projectile-setup-indexing)

(push "*.mypy_cache" projectile-globally-ignored-directories)
(push "*.bloop" projectile-globally-ignored-directories)

;; Opens project root when using projectile-switch-project (C-c p p)
(setq projectile-switch-project-action #'projectile-dired)
