(use-package org
  :straight t
  :bind (("M-p" . org-metaup)
         ("M-n" . org-metadown)
         ("C-x M-p" . org-metaleft)
         ("C-x M-n" . org-metaright))
  )

(use-package htmlize
  :straight t)
