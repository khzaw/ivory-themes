# Ivory Theme

Ivory is a minimal, near-monochromatic Emacs theme package with two variants:

- `ivory-light`
- `ivory-dark`

Most syntax contrast comes from weight, foreground intensity, and background
surfaces.  Git and diff faces keep red/green directionality by default.

## Local Development

For fast iteration from this checkout, load it directly instead of letting
straight clone and rebuild a copy:

```elisp
(use-package ivory-themes
  :straight nil
  :load-path "~/Code/personal/ivory-theme"
  :init
  (add-to-list 'custom-theme-load-path
               (expand-file-name "~/Code/personal/ivory-theme"))
  :custom
  (ivory-theme-bold-constructs t)
  (ivory-theme-italic-constructs nil)
  :config
  ;; (load-theme 'ivory-light t)
  ;; (load-theme 'ivory-dark t)
  (define-key global-map (kbd "<f6>") #'ivory-theme-toggle))
```

After editing theme files, run `M-x load-theme` again, or evaluate:

```elisp
(mapc #'disable-theme custom-enabled-themes)
(load-theme 'ivory-light t)
```

## Palette Overrides

Set overrides before loading the theme.  Diff colors are regular palette
entries, so they can be tuned without editing the face definitions.

```elisp
(setq ivory-theme-light-palette-overrides
      '((bg-added . "#d5f5df")
        (bg-removed . "#ffe0de")
        (fg-added . "#005a00")
        (fg-removed . "#990f0f")))
```

Shared overrides go in `ivory-theme-common-palette-overrides`; variant-specific
overrides go in `ivory-theme-light-palette-overrides` or
`ivory-theme-dark-palette-overrides`.
