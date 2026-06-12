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

(defun ivory-themes-test--face-attributes (face faces)
  "Return FACE attributes from FACES."
  (let ((entry (assq face faces)))
    (unless entry
      (error "Missing face spec for %S" face))
    (cadr (car (cadr entry)))))

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

(ert-deftest ivory-themes-test-internal-border-follows-base-background ()
  "Internal frame padding uses the same background as the editor."
  (let ((ivory-themes-soft-backgrounds t))
    (dolist (variant '(light dark))
      (let* ((palette (ivory-themes--palette variant))
             (bg (alist-get 'bg palette))
             (internal-border (assq 'internal-border
                                    (ivory-themes--faces-basic palette))))
        (should (equal internal-border
                       `(internal-border ((t (:background ,bg))))))))))

(ert-deftest ivory-themes-test-solaire-remapped-faces-follow-base-surface ()
  "Solaire buffers should not reveal contrasting frame padding."
  (let ((ivory-themes-soft-backgrounds t))
    (dolist (variant '(light dark))
      (let* ((palette (ivory-themes--palette variant))
             (bg (alist-get 'bg palette))
             (bg-subtle (alist-get 'bg-subtle palette))
             (bg-region (alist-get 'bg-region palette))
             (fg (alist-get 'fg palette))
             (fg-faint (alist-get 'fg-faint palette))
             (faces (ivory-themes--faces-modelines-extra palette)))
        (should (equal (assq 'solaire-default-face faces)
                       `(solaire-default-face ((t (:background ,bg :foreground ,fg))))))
        (should (equal (assq 'solaire-fringe-face faces)
                       `(solaire-fringe-face ((t (:background ,bg :foreground ,fg-faint))))))
        (should (equal (assq 'solaire-line-number-face faces)
                       `(solaire-line-number-face ((t (:background ,bg :foreground ,fg-faint))))))
        (should (equal (assq 'solaire-hl-line-face faces)
                       `(solaire-hl-line-face ((t (:background ,bg-subtle :extend t))))))
        (should (equal (assq 'solaire-region-face faces)
                       `(solaire-region-face ((t (:background ,bg-region :foreground ,fg :extend t))))))
        (should (equal (assq 'solaire-org-hide-face faces)
                       `(solaire-org-hide-face ((t (:background ,bg :foreground ,bg))))))))))

(ert-deftest ivory-themes-test-dired-metadata-faces-avoid-backgrounds ()
  "Dired metadata and privilege columns should not paint color blocks."
  (dolist (variant '(light dark))
    (let ((faces (ivory-themes--faces-files-buffers
                  (ivory-themes--palette variant))))
      (dolist (face '(dired-perm-write
                      dired-set-id
                      dired-special
                      diredfl-autofile-name
                      diredfl-compressed-file-name
                      diredfl-compressed-file-suffix
                      diredfl-date-time
                      diredfl-dir-heading
                      diredfl-dir-name
                      diredfl-dir-priv
                      diredfl-exec-priv
                      diredfl-executable-tag
                      diredfl-file-name
                      diredfl-file-suffix
                      diredfl-ignored-file-name
                      diredfl-link-priv
                      diredfl-no-priv
                      diredfl-number
                      diredfl-other-priv
                      diredfl-rare-priv
                      diredfl-read-priv
                      diredfl-symlink
                      diredfl-tagged-autofile-name
                      diredfl-write-priv))
        (should-not
         (plist-member (ivory-themes-test--face-attributes face faces)
                       :background))))))

(ert-deftest ivory-themes-test-shell-faces-stay-distinct ()
  "Shell-specific constructs keep separate monochrome roles."
  (let ((ivory-themes-bold-constructs t))
    (dolist (variant '(light dark))
      (let* ((palette (ivory-themes--palette variant))
             (faces (ivory-themes--faces-font-lock palette))
             (heredoc (ivory-themes-test--face-attributes
                       'sh-heredoc faces))
             (quoted-exec (ivory-themes-test--face-attributes
                           'sh-quoted-exec faces)))
        (should (equal (plist-get heredoc :foreground)
                       (alist-get 'fg-string palette)))
        (should (equal (plist-get heredoc :background)
                       (alist-get 'bg-block palette)))
        (should (eq (plist-get heredoc :extend) t))
        (should (equal (plist-get quoted-exec :foreground)
                       (alist-get 'fg-syntax palette)))
        (should-not (equal (plist-get quoted-exec :foreground)
                           (alist-get 'fg-string palette)))
        (should (eq (plist-get quoted-exec :weight) 'bold))))))

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
