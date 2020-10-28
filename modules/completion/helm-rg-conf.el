(if (is-windows)
    ;; Only necessary until fixed in helm-rg:
    ;; See: https://github.com/cosmicexplorer/helm-rg/issues/10#issuecomment-636401523

    ;; Add an overloaded function definition for helm-rg so that it works in Windows
    (defun win-helm-rg ()
      (interactive)
      (if (is-windows)
          (progn
            (defconst helm-rg--ripgrep-argv-format-alist
              `((helm-rg-ripgrep-executable :face helm-rg-base-rg-cmd-face)
                ((->> helm-rg--case-sensitive-argument-alist
                      (helm-rg--alist-get-exhaustive helm-rg--case-sensitivity))
                 :face helm-rg-active-arg-face)
                ("--color=ansi" :face helm-rg-inactive-arg-face)
                ((helm-rg--construct-match-color-format-arguments)
                 :face helm-rg-inactive-arg-face)
                ((unless (helm-rg--empty-glob-p helm-rg--glob-string)
                   (list "-g" helm-rg--glob-string))
                 :face helm-rg-active-arg-face)
                ;; ATTN: Inserted line below
                ("-p" :face helm-rg-inactive-arg-face)
                (helm-rg--extra-args :face helm-rg-extra-arg-face)
                (it
                 :face font-lock-string-face)
                ((helm-rg--process-paths-to-search helm-rg--paths-to-search)
                 :face helm-rg-directory-cmd-face))
              "Alist mapping (sexp -> face) describing how to generate and propertize the argv for ripgrep.")
            (defun helm-rg (rg-pattern &optional pfx paths)
              "Search for the PCRE regexp RG-PATTERN extremely quickly with ripgrep.

When invoked interactively with a prefix argument, or when PFX is non-nil,
set the cwd for the ripgrep process to `default-directory'. Otherwise use the
cwd as described by `helm-rg-default-directory'.

If PATHS is non-nil, ripgrep will search only those paths, relative to the
process's cwd. Otherwise, the process's cwd will be searched.

Note that ripgrep respects glob patterns from .gitignore, .rgignore, and .ignore
files, excluding files matching those patterns. This composes with the glob
defined by `helm-rg-default-glob-string', which only finds files matching the
glob, and can be overridden with `helm-rg--set-glob', which is defined in
`helm-rg-map'.

There are many more `defcustom' forms, which are visible by searching for \"defcustom\" in the
`helm-rg' source (which can be located using `find-function'). These `defcustom' forms set defaults
for options which can be modified while invoking `helm-rg' using the keybindings listed below.

The ripgrep command's help output can be printed into its own buffer for
reference with the interactive command `helm-rg-display-help'.

\\{helm-rg-map}"
              (interactive (list (helm-rg--get-thing-at-pt) current-prefix-arg nil))
              (let* ((helm-rg--current-dir
                      (or helm-rg--current-dir
                          (and pfx default-directory)
                          (helm-rg--interpret-starting-dir helm-rg-default-directory)))
                     ;; TODO: make some declarative way to ensure these variables are all initialized and
                     ;; destroyed (an alist `defconst' should do the trick)!
                     (helm-rg--glob-string
                      (or helm-rg--glob-string
                          helm-rg-default-glob-string))
                     (helm-rg--extra-args
                      (or helm-rg--extra-args
                          helm-rg-default-extra-args))
                     (helm-rg--paths-to-search
                      (or helm-rg--paths-to-search
                          ;; ATTN: Modified line below
                          (or paths (list helm-rg--current-dir))))
                     (helm-rg--case-sensitivity
                      (or helm-rg--case-sensitivity
                          helm-rg-default-case-sensitivity)))
                ;; FIXME: make all the `defvar's into buffer-local variables (or give them local counterparts)?
                ;; the idea is that `helm-resume' can be applied and work with the async action -- currently it
                ;; tries to find a buffer which we killed in the cleanup here when we do the async action
                ;; (i think)
                (setq helm-rg--last-dir helm-rg--current-dir)
                (unwind-protect (helm-rg--do-helm-rg rg-pattern)
                  (helm-rg--unwind-cleanup))))))))
