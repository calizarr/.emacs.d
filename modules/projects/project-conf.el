;; -*- lexical-binding: t; -*-

;;; project-conf --- Project management via the built-in project.el
;;; Commentary:
;;
;; Replaces projectile.  Everything below is either built into Emacs or a
;; couple of lines of glue.
;;
;; There is no `.projectile' equivalent -- per-project configuration is done
;; with the standard Emacs mechanisms instead:
;;
;;   Ignoring files  `.gitignore', honored automatically because
;;                   `project-files' shells out to `git ls-files'.  For
;;                   non-VC ignores, set `project-vc-ignores' in the
;;                   project's `.dir-locals.el' (already a safe local
;;                   variable, so no prompt).
;;
;;   Marking a root  Add a file name or glob to
;;                   `project-vc-extra-root-markers' below.
;;
;; `projection' (see the optional stage-2 block at the bottom) follows the
;; same convention: per-project compile commands live in `.dir-locals.el'.
;;
;;; Code:

(require 'seq)

(defun my/project-root ()
  "Return the current project root, or `default-directory' outside a project.
Drop-in replacement for `projectile-project-root'."
  (require 'project)
  (if-let* ((proj (project-current nil)))
      (project-root proj)
    default-directory))

(use-package project
  :ensure nil                           ; built in

  ;; project.el gets loaded during startup by other packages anyway (magit,
  ;; treemacs, consult), so there is no laziness left to protect -- demand it
  ;; and bind the prefix for real.  `:bind-keymap' was the obvious choice here
  ;; but it leaves `C-c p' bound to a use-package AUTOLOAD STUB rather than to
  ;; the keymap, even after project.el is loaded.  A function is not a keymap,
  ;; so `key-binding' cannot descend it and `which-key' / the embark prefix
  ;; help cannot introspect the prefix -- `C-c p' would pop up nothing.  See
  ;; the `keymap-global-set' in `:config' below.
  :demand t

  :init
  ;; Was `projectile-switch-project-action #'projectile-dired'.  A bare symbol
  ;; runs that command immediately; remove this line to get the dispatch menu
  ;; (Find file / Find regexp / Dired / VC-Dir / Eshell / ...) instead.
  (setq project-switch-commands #'project-dired)

  ;; Replaces `projectile-globally-ignored-directories'.  Only global and
  ;; directory-local values are honored, so per-project additions belong in
  ;; that project's `.dir-locals.el'.  Mostly redundant for git projects,
  ;; where `.gitignore' already covers these.
  (setq project-vc-ignores '(".mypy_cache/" ".tree-sitter/" ".bloop/"))

  ;; Deliberately EMPTY -- the project root stays the git repo root.
  ;;
  ;; `project-try-vc--search' finds the root with `locate-dominating-file',
  ;; which stops at the FIRST (innermost) directory holding a marker.  So a
  ;; marker like "package.json" or "go.mod" in a subdirectory of a git repo
  ;; makes that subdirectory its own project -- verified: with the marker set,
  ;; ~/code/claude-code/cx-tools/ roots at itself instead of at
  ;; ~/code/claude-code/.
  ;;
  ;; That matters beyond search, because `claude-code-ide' derives its working
  ;; directory from `project-root' (claude-code-ide.el:674).  Narrowing the
  ;; root splits sessions and transcripts across separate
  ;; ~/.claude/projects/<slug>/ folders depending on which subdirectory the
  ;; current buffer happens to live in -- the same class of misrooting as the
  ;; 2026-07-21 `~/code/.projectile' incident, just inverted.
  ;;
  ;; ---------------------------------------------------------------------
  ;; Opting IN, per repo or per directory
  ;;
  ;; This list is read via `project--value-in-dir', which resolves it through
  ;; DIR-LOCALS rather than just the global value.  So subproject behavior can
  ;; be switched on exactly where it is wanted, while staying off everywhere
  ;; else.  The variable is already a `safe-local-variable' -- no prompt.
  ;;
  ;; Placement decides the blast radius, because dir-locals apply DOWNWARD to
  ;; the whole subtree.  Both of these were verified on throwaway repos:
  ;;
  ;;   A) at the repo root -> EVERY marker-bearing subdir becomes its own
  ;;      project.  Repo-wide opt-in.
  ;;
  ;;        repo/.dir-locals.el   ((nil . ((project-vc-extra-root-markers
  ;;                                        . ("package.json")))))
  ;;        repo/a/package.json   -> project root is repo/a/
  ;;        repo/b/package.json   -> project root is repo/b/
  ;;        repo/c/              -> project root is repo/   (no marker)
  ;;
  ;;   B) inside one subdir -> ONLY that subdir becomes its own project.
  ;;      Surgical; sibling dirs are unaffected even if they hold the same
  ;;      marker file.
  ;;
  ;;        repo/b/.dir-locals.el  (same contents as above)
  ;;        repo/a/package.json   -> project root is repo/    (no dir-locals)
  ;;        repo/b/package.json   -> project root is repo/b/
  ;;
  ;; Case B has a neat degenerate form: name `.dir-locals.el' as its OWN
  ;; marker, and the file becomes a pure "this directory is a project root"
  ;; flag -- no package.json or other build file needs to exist.  This is the
  ;; real replacement for a per-directory `.projectile', in one self-contained
  ;; file that needs no global configuration:
  ;;
  ;;   ((nil . ((project-vc-extra-root-markers . (".dir-locals.el")))))
  ;;
  ;; Verified: a directory holding exactly that roots at itself, while a
  ;; sibling without it still resolves to the git repo root.
  ;;
  ;; Remember this also moves `claude-code-ide' for that directory -- which is
  ;; the point when you opt in deliberately, and the bug when it is global.
  ;; ---------------------------------------------------------------------
  (setq project-vc-extra-root-markers nil)

  ;; Projectile put an indicator in the mode line; project.el has its own
  ;; (project name + a Project menu).  Set to `non-remote' to skip it for
  ;; TRAMP buffers.
  (setq project-mode-line t)

  :config
  ;; NOTE: this is the ONLY project prefix in this config.  project.el
  ;; autoloads `(define-key ctl-x-map "p" project-prefix-map)', but
  ;; `modules/core/custom-stuff.el:64' does
  ;;     (global-set-key (kbd "C-x p") (kbd "C-u -1 C-x o"))
  ;; which writes into `ctl-x-map' and shadows it -- `C-x p' is
  ;; previous-window here, not a project prefix.  Verified: (key-binding
  ;; (kbd "C-x p")) => "-1o".  So do not assume `C-x p' is a fallback.
  ;;
  ;; Binding the keymap OBJECT (not a `:bind-keymap' stub) is what keeps
  ;; `C-c p' a real prefix for `which-key' and `key-binding'.
  (keymap-global-set "C-c p" project-prefix-map)

  ;; Projectile's search commands lived under `C-c p s'.  Rebuild that prefix.
  ;; `consult-ripgrep' resolves the project root itself via
  ;; `consult-project-function', which now defaults to project.el -- so the
  ;; old `my-project-ripgrep' wrapper is no longer needed.
  (defun my/ripgrep-here ()
    "Ripgrep `default-directory' and everything below it.
Narrows the search to the current subtree instead of the whole project.
Note this is still RECURSIVE -- rg descends by default, so this is the
current directory *and all its subdirectories*, just rooted lower than
\\[consult-ripgrep].  Keeping the two as separate commands is what lets the
project root stay the git repo root -- see the
`project-vc-extra-root-markers' note above."
    (interactive)
    (consult-ripgrep default-directory))

  (defvar-keymap my/project-search-map
    :doc "Project search commands (projectile's `C-c p s' prefix)."
    "r" #'consult-ripgrep              ; whole git repo, recursive
    "d" #'my/ripgrep-here              ; this directory down, recursive
    "g" #'project-find-regexp
    "G" #'project-or-external-find-regexp)

  (keymap-set project-prefix-map "s" my/project-search-map)
  ;; `s' was `project-shell'; relocate it rather than lose it.
  (keymap-set project-prefix-map "C-s" #'project-shell)
  ;; Projectile's `C-c p S' (`projectile-save-project-buffers').
  (keymap-set project-prefix-map "S" #'project-save-some-buffers))

;;; Muscle memory: what carries over unchanged under `C-c p'
;;
;;   p  switch project      f  find file        d  find directory
;;   b  switch to buffer    k  kill buffers     D  dired
;;   v  vc-dir              c  compile          !  shell command
;;   &  async shell command r  query replace    s r  ripgrep  (rebuilt above)
;;
;; Two that moved:
;;   e  was projectile-recentf, is now `project-eshell'
;;   a  was projectile-find-other-file -- no built-in equivalent
;;      (`projection-find-other-file' covers it, see stage 2)
;;
;; New, no projectile equivalent:
;;   x  `project-execute-extended-command'  (M-x scoped to the project root)
;;   o  `project-any-command'               (run any command in the project)
;;   C-b `project-list-buffers'

;;; Stage 2 (optional) --- projection, for multi-target compilation.
;;
;; The one thing projectile never had: discovering every build/test target in
;; a project (Makefile, package.json scripts, cargo, tox, justfile, ...) and
;; offering them through completing-read.  Uncomment to enable; this pulls in
;; `projection', `projection-multi', `projection-multi-embark' and
;; `compile-multi' (a separate package -- it is not in projection's
;; Package-Requires).
;;
;; (use-package projection
;;   :ensure t
;;   :hook (after-init . global-projection-hook-mode)
;;   :hook (compilation-mode . projection-customize-compilation-mode)
;;   :init
;;   (setq compilation-buffer-name-function
;;         #'projection-customize-compilation-buffer-name-function)
;;   :config
;;   ;; Per-project compile commands set in `.dir-locals.el' without prompting.
;;   (dolist (sym '(projection-commands-configure-project
;;                  projection-commands-build-project
;;                  projection-commands-test-project
;;                  projection-commands-run-project
;;                  projection-commands-package-project
;;                  projection-commands-install-project))
;;     (put sym 'safe-local-variable #'stringp))
;;   ;; Fills projectile's `C-c p a'.
;;   (keymap-set project-prefix-map "a" #'projection-find-other-file)
;;   (keymap-set project-prefix-map "I" #'projection-ibuffer)
;;   ;; The rest of projection's own commands.
;;   :bind-keymap ("C-c P" . projection-map))
;;
;; (use-package projection-multi
;;   :ensure t
;;   :bind (:map project-prefix-map
;;               ("RET" . projection-multi-compile)))
;;
;; (use-package projection-multi-embark
;;   :ensure t
;;   :after (embark projection-multi)
;;   :demand t
;;   :config (projection-multi-embark-setup-command-map))

(provide 'project-conf)
;;; project-conf.el ends here
