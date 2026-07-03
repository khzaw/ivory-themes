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

(defun ivory-themes-test--reset-light-theme ()
  "Return `ivory-light' to a pristine, disabled state.
`disable-theme' leaves stale entries in the theme's `theme-settings',
so a later `custom-theme-set-faces' appends instead of replacing and
an old face spec can win on re-enable.  Clearing `theme-settings'
keeps integration tests independent of one another."
  (when (memq 'ivory-light custom-enabled-themes)
    (disable-theme 'ivory-light))
  (put 'ivory-light 'theme-settings nil))

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

(ert-deftest ivory-themes-test-whitespace-tabs-stand-out-from-spaces ()
  "Visible tabs should have a stronger cue than ordinary space markers."
  (dolist (variant '(light dark))
    (let* ((palette (ivory-themes--palette variant))
           (faces (ivory-themes--faces-basic palette))
           (space (ivory-themes-test--face-attributes
                   'whitespace-space faces))
           (tab (ivory-themes-test--face-attributes
                 'whitespace-tab faces)))
      (should (equal (plist-get space :foreground)
                     (alist-get 'fg-faint palette)))
      (should-not (plist-member space :background))
      (should (equal (plist-get tab :background)
                     (alist-get 'bg-block palette)))
      (should (equal (plist-get tab :foreground)
                     (alist-get 'fg-alt palette)))
      (should (eq (plist-get tab :weight) 'bold))
      (should-not (equal (plist-get tab :foreground)
                         (plist-get space :foreground))))))

(ert-deftest ivory-themes-test-makefile-space-avoids-hotpink-default ()
  "Makefile whitespace warnings should use Ivory roles, not Emacs hotpink."
  (dolist (variant '(light dark))
    (let* ((palette (ivory-themes--palette variant))
           (faces (ivory-themes--faces-font-lock palette))
           (space (ivory-themes-test--face-attributes
                   'makefile-space faces)))
      (should (equal (plist-get space :background)
                     (alist-get 'bg-block palette)))
      (should (equal (plist-get space :foreground)
                     (alist-get 'fg-removed palette)))
      (should (equal (plist-get (plist-get space :underline) :color)
                     (alist-get 'fg-removed palette)))
      (should (eq (plist-get space :weight) 'bold))
      (should-not (equal (plist-get space :background) "hotpink")))))

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

(ert-deftest ivory-themes-test-code-backgrounds-stand-away-from-editor ()
  "Code surfaces stay visually distinct in pure and softened backgrounds."
  (dolist (soft '(nil t))
    (let ((ivory-themes-soft-backgrounds soft))
      (dolist (variant '(light dark))
        (let ((palette (ivory-themes--palette variant)))
          (should (>= (ivory-themes-test--contrast-ratio
                       (alist-get 'bg palette)
                       (alist-get 'bg-code-block palette))
                      1.08))
          (should (>= (ivory-themes-test--contrast-ratio
                       (alist-get 'bg palette)
                       (alist-get 'bg-code-inline palette))
                      1.12)))))))

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

(ert-deftest ivory-themes-test-writing-code-faces-use-dedicated-surfaces ()
  "Org and Markdown code faces use stronger code-specific surfaces."
  (dolist (variant '(light dark))
    (let* ((palette (ivory-themes--palette variant))
           (faces (ivory-themes--faces-org-markdown palette))
           (bg-code-block (alist-get 'bg-code-block palette))
           (bg-code-inline (alist-get 'bg-code-inline palette))
           (fg-alt (alist-get 'fg-alt palette)))
      (dolist (face '(org-block markdown-code-face))
        (should (equal (plist-get (ivory-themes-test--face-attributes face faces)
                                  :background)
                       bg-code-block)))
      (dolist (face '(markdown-ts-code-block md-ts-code))
        (should (eq (plist-get (ivory-themes-test--face-attributes face faces)
                               :inherit)
                    'markdown-code-face)))
      (dolist (face '(org-code org-verbatim org-inline-src-block
                      markdown-inline-code-face))
        (let ((attributes (ivory-themes-test--face-attributes face faces)))
          (should (equal (plist-get attributes :background) bg-code-inline))
          (should (equal (plist-get attributes :foreground) fg-alt))
          (should (equal (plist-get (plist-get attributes :box) :color)
                         bg-code-inline))))
      (dolist (face '(markdown-ts-code-span md-ts-inline-code))
        (should (eq (plist-get (ivory-themes-test--face-attributes face faces)
                               :inherit)
                    'markdown-inline-code-face))))))

(ert-deftest ivory-themes-test-magit-current-branch-stands-out ()
  "The current branch should differ from local branches and neutral tags."
  (dolist (variant '(light dark))
    (let* ((palette (ivory-themes--palette variant))
           (faces (ivory-themes--faces-vcs palette))
           (current (ivory-themes-test--face-attributes
                     'magit-branch-current faces))
           (tag (ivory-themes-test--face-attributes
                 'magit-tag faces))
           (local (ivory-themes-test--face-attributes
                   'magit-branch-local faces)))
      (should (eq (plist-get current :weight) 'bold))
      (should (eq (plist-get local :weight) 'bold))
      (should (equal (plist-get current :background)
                     (alist-get 'bg-branch-current palette)))
      (should (equal (plist-get (plist-get current :box) :color)
                     (alist-get 'branch-current-border palette)))
      (should (equal (plist-get tag :background)
                     (alist-get 'bg-active palette)))
      (should (equal (plist-get (plist-get tag :box) :color)
                     (alist-get 'border palette)))
      (should-not (equal (plist-get current :background)
                         (plist-get tag :background)))
      (should-not (equal (plist-get (plist-get current :box) :color)
                         (plist-get (plist-get tag :box) :color)))
      (should-not (plist-member local :background))
      (should-not (plist-member local :box)))))

(ert-deftest ivory-themes-test-forge-pull-request-states-stay-distinct ()
  "Forge pull request states should be distinguishable without loud colors."
  (dolist (variant '(light dark))
    (let* ((palette (ivory-themes--palette variant))
           (faces (ivory-themes--faces-vcs palette))
           (open (ivory-themes-test--face-attributes
                  'forge-pullreq-open faces))
           (merged (ivory-themes-test--face-attributes
                    'forge-pullreq-merged faces))
           (rejected (ivory-themes-test--face-attributes
                      'forge-pullreq-rejected faces))
           (draft (ivory-themes-test--face-attributes
                   'forge-pullreq-draft faces)))
      (should (equal (plist-get open :foreground)
                     (alist-get 'fg palette)))
      (should (equal (plist-get merged :foreground)
                     (alist-get 'border palette)))
      (should (eq (plist-get merged :strike-through) t))
      (should (eq (plist-get merged :weight) 'normal))
      (should-not (plist-member merged :box))
      (should (equal (plist-get rejected :foreground)
                     (alist-get 'red-faint palette)))
      (should (eq (plist-get rejected :strike-through) t))
      (should (eq (plist-get rejected :weight) 'normal))
      (should-not (plist-member open :underline))
      (should-not (plist-member merged :underline))
      (should-not (plist-member rejected :underline))
      (should-not (plist-member draft :underline))
      (should (equal (plist-get draft :background)
                     (alist-get 'bg-block palette)))
      (should-not (plist-member draft :foreground))
      (should-not (equal (plist-get open :foreground)
                         (plist-get merged :foreground)))
      (should-not (equal (plist-get merged :foreground)
                         (plist-get rejected :foreground))))))

(ert-deftest ivory-themes-test-forge-status-faces-compose-with-states ()
  "Forge notification status faces should not replace state colors."
  (dolist (variant '(light dark))
    (let* ((palette (ivory-themes--palette variant))
           (faces (ivory-themes--faces-vcs palette))
           (unread (ivory-themes-test--face-attributes
                    'forge-topic-unread faces))
           (pending (ivory-themes-test--face-attributes
                     'forge-topic-pending faces))
           (done (ivory-themes-test--face-attributes
                  'forge-topic-done faces)))
      (should-not (plist-member unread :foreground))
      (should-not (plist-member pending :foreground))
      (should-not (plist-member done :foreground))
      (should-not (plist-member unread :weight))
      (should-not (plist-member unread :box))
      (should-not (plist-member pending :weight))
      (should-not (plist-member pending :box))
      (should-not (plist-member pending :underline)))))

(ert-deftest ivory-themes-test-forge-labels-use-tag-chip-roles ()
  "Forge labels should read as restrained chips, not selections."
  (dolist (variant '(light dark))
    (let* ((palette (ivory-themes--palette variant))
           (faces (ivory-themes--faces-vcs palette))
           (label (ivory-themes-test--face-attributes
                   'forge-topic-label faces)))
      (should (equal (plist-get label :background)
                     (alist-get 'bg-active palette)))
      (should (equal (plist-get label :foreground)
                     (alist-get 'fg-alt palette)))
      (should-not (equal (plist-get label :background)
                         (alist-get 'bg-region palette))))))

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

(ert-deftest ivory-themes-test-soft-background-toggle-affects-default-face ()
  "Toggling soft backgrounds reloads with a softened default face.
Regression test for the apply-then-enable order in `ivory-themes-load'."
  (let ((theme-dir (file-name-directory (locate-library "ivory-themes")))
        (old-soft ivory-themes-soft-backgrounds)
        (old-light ivory-themes-light-palette-overrides)
        (old-common ivory-themes-common-palette-overrides)
        (old-ctlp custom-theme-load-path))
    (unwind-protect
        (progn
          (setq ivory-themes-soft-backgrounds nil
                ivory-themes-light-palette-overrides nil
                ivory-themes-common-palette-overrides nil
                custom-theme-load-path (list theme-dir))
          (ivory-themes-test--reset-light-theme)
          (ivory-themes-load 'ivory-light)
          (should (equal (face-background 'default) "#ffffff"))
          (ivory-themes-toggle-soft-backgrounds)
          (should (equal (face-background 'default) "#f8f8f8")))
      (setq ivory-themes-soft-backgrounds old-soft
            ivory-themes-light-palette-overrides old-light
            ivory-themes-common-palette-overrides old-common
            custom-theme-load-path old-ctlp)
      (ivory-themes-test--reset-light-theme)
      (when (memq 'ivory-dark custom-enabled-themes)
        (disable-theme 'ivory-dark)))))

(ert-deftest ivory-themes-test-reload-applies-changed-palette-override ()
  "Reloading an already-loaded theme picks up a changed override.
Regression test for the apply-then-enable order in `ivory-themes-load'."
  (let ((theme-dir (file-name-directory (locate-library "ivory-themes")))
        (old-soft ivory-themes-soft-backgrounds)
        (old-light ivory-themes-light-palette-overrides)
        (old-common ivory-themes-common-palette-overrides)
        (old-ctlp custom-theme-load-path))
    (unwind-protect
        (progn
          (setq ivory-themes-soft-backgrounds nil
                ivory-themes-common-palette-overrides nil
                ivory-themes-light-palette-overrides '((bg . "#f0fff0"))
                custom-theme-load-path (list theme-dir))
          (ivory-themes-test--reset-light-theme)
          (ivory-themes-load 'ivory-light)
          (should (equal (face-background 'default) "#f0fff0"))
          (setq ivory-themes-light-palette-overrides '((bg . "#fff0f0")))
          (ivory-themes-load 'ivory-light)
          (should (equal (face-background 'default) "#fff0f0")))
      (setq ivory-themes-soft-backgrounds old-soft
            ivory-themes-light-palette-overrides old-light
            ivory-themes-common-palette-overrides old-common
            custom-theme-load-path old-ctlp)
      (ivory-themes-test--reset-light-theme)
      (when (memq 'ivory-dark custom-enabled-themes)
        (disable-theme 'ivory-dark)))))

(provide 'ivory-themes-tests)

;;; ivory-themes-tests.el ends here
