;;; ivory-themes-tests.el --- Tests for Ivory themes -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Kaung Htet
;; SPDX-License-Identifier: MIT

;;; Commentary:

;; Tests for palette invariants and user override validation.

;;; Code:

(require 'ert)
(require 'cl-lib)
(require 'ivory-themes)

(defun ivory-themes-test--relative-luminance (hex)
  "Return WCAG relative luminance for HEX."
  (let* ((r (/ (string-to-number (substring hex 1 3) 16) 255.0))
         (g (/ (string-to-number (substring hex 3 5) 16) 255.0))
         (b (/ (string-to-number (substring hex 5 7) 16) 255.0)))
    (cl-labels ((linearize (channel)
                  (if (<= channel 0.03928)
                      (/ channel 12.92)
                    (expt (/ (+ channel 0.055) 1.055) 2.4))))
      (+ (* 0.2126 (linearize r))
         (* 0.7152 (linearize g))
         (* 0.0722 (linearize b))))))

(defun ivory-themes-test--contrast-ratio (left right)
  "Return WCAG contrast ratio between LEFT and RIGHT."
  (let ((left-luminance (ivory-themes-test--relative-luminance left))
        (right-luminance (ivory-themes-test--relative-luminance right)))
    (/ (+ (max left-luminance right-luminance) 0.05)
       (+ (min left-luminance right-luminance) 0.05))))

(ert-deftest ivory-themes-test-palette-roles-match ()
  "Theme variants expose the same semantic palette roles."
  (should-not
   (ivory-themes--validate-palette-specs)))

(ert-deftest ivory-themes-test-background-anchors-default-to-endpoints ()
  "Default backgrounds use pure display endpoints."
  (should (equal (alist-get 'bg (alist-get 'light ivory-themes-palettes))
                 "#ffffff"))
  (should (equal (alist-get 'bg (alist-get 'dark ivory-themes-palettes))
                 "#000000")))

(ert-deftest ivory-themes-test-soft-backgrounds-avoid-endpoints ()
  "Soft backgrounds avoid pure display endpoints when enabled."
  (let ((ivory-themes-soft-backgrounds t))
    (should (equal (alist-get 'bg (ivory-themes--palette 'light))
                   "#f8f8f8"))
    (should (equal (alist-get 'bg (ivory-themes--palette 'dark))
                   "#080808")))
  (let ((ivory-themes-soft-backgrounds t)
        (ivory-themes-light-palette-overrides '((bg . "#fafafa"))))
    (should (equal (alist-get 'bg (ivory-themes--palette 'light))
                   "#fafafa"))))

(ert-deftest ivory-themes-test-adjacent-background-contrast ()
  "Adjacent editor surfaces keep subtle contrast from the base background."
  (let* ((light (alist-get 'light ivory-themes-palettes))
         (dark (alist-get 'dark ivory-themes-palettes)))
    (dolist (role '(bg-alt bg-subtle bg-modeline-inactive))
      (should (>= (ivory-themes-test--contrast-ratio
                   (alist-get 'bg light) (alist-get role light))
                  1.05))
      (should (>= (ivory-themes-test--contrast-ratio
                   (alist-get 'bg dark) (alist-get role dark))
                  1.05)))))

(ert-deftest ivory-themes-test-soft-adjacent-background-contrast ()
  "Soft background mode preserves adjacent surface contrast."
  (let* ((ivory-themes-soft-backgrounds t)
         (light (ivory-themes--palette 'light))
         (dark (ivory-themes--palette 'dark)))
    (dolist (role '(bg-alt bg-subtle bg-modeline-inactive))
      (should (>= (ivory-themes-test--contrast-ratio
                   (alist-get 'bg light) (alist-get role light))
                  1.05))
      (should (>= (ivory-themes-test--contrast-ratio
                   (alist-get 'bg dark) (alist-get role dark))
                  1.05)))))

(ert-deftest ivory-themes-test-readable-text-contrast ()
  "Readable foreground roles keep a minimum contrast against the base bg."
  (dolist (variant '(light dark))
    (let* ((palette (alist-get variant ivory-themes-palettes))
           (bg (alist-get 'bg palette)))
      (dolist (role '(fg fg-alt fg-name fg-syntax fg-string fg-comment
                         fg-comment-delimiter fg-dim fg-faint fg-inactive))
        (should (>= (ivory-themes-test--contrast-ratio
                     bg (alist-get role palette))
                    3.0))))))

(ert-deftest ivory-themes-test-ansi-blue-uses-blue-role ()
  "ANSI color variables use the public `blue' palette role."
  (dolist (variant '(light dark))
    (let* ((palette (alist-get variant ivory-themes-palettes))
           (vector (cadr (assq 'ansi-color-names-vector
                               (ivory-themes--variables palette)))))
      (should (equal (aref vector 4)
                     (alist-get 'blue palette))))))

(ert-deftest ivory-themes-test-override-validation ()
  "Palette overrides reject unknown roles and invalid colors."
  (should (equal (ivory-themes--validate-palette-overrides
                  '((fg-comment . "#888888")) "test")
                 '((fg-comment . "#888888"))))
  (should-error
   (ivory-themes--validate-palette-overrides
    '((fg-commentt . "#888888")) "test")
   :type 'user-error)
  (should-error
   (ivory-themes--validate-palette-overrides
    '((fg-comment . "not-a-color")) "test")
   :type 'user-error))

(provide 'ivory-themes-tests)

;;; ivory-themes-tests.el ends here
