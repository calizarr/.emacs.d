# -*- mode: snippet -*-
# name: elisp-init
# key: elisp
# --
;;; `(file-name-nondirectory (buffer-file-name))` ---  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

$0

(provide '`(file-name-nondirectory (file-name-sans-extension (buffer-file-name)))`)
