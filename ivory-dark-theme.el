;;; ivory-dark-theme.el --- Dark variant of Ivory theme -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Kaung Htet
;; SPDX-License-Identifier: MIT

;;; Commentary:

;; Dark, near-monochromatic Ivory theme.

;;; Code:

(require 'ivory-themes)

(deftheme ivory-dark
  "A minimal dark monochromatic theme with restrained diff colors.")

(ivory-themes-apply 'ivory-dark 'dark)

(provide-theme 'ivory-dark)

;;; ivory-dark-theme.el ends here
