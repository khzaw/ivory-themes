;;; ivory-light-theme.el --- Light variant of Ivory theme -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Kaung Htet
;; SPDX-License-Identifier: MIT

;;; Commentary:

;; Light, near-monochromatic Ivory theme.

;;; Code:

(require 'ivory-themes)

(deftheme ivory-light
  "A minimal light monochromatic theme with restrained diff colors.")

(ivory-themes--apply 'ivory-light 'light)

(provide-theme 'ivory-light)

;;; ivory-light-theme.el ends here
