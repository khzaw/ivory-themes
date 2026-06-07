;;; ivory-dark-theme.el --- Dark variant of Ivory theme -*- lexical-binding: t; -*-

;;; Commentary:

;; Dark, near-monochromatic Ivory theme.

;;; Code:

(require 'ivory-themes)

(deftheme ivory-dark
  "A minimal dark monochromatic theme with restrained diff colors.")

(ivory-theme-apply 'ivory-dark 'dark)

(provide-theme 'ivory-dark)

;;; ivory-dark-theme.el ends here
