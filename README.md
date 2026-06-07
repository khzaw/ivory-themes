# Ivory Theme

Ivory is a minimal, near-monochromatic Emacs theme package with two variants:

- `ivory-light`
- `ivory-dark`

Most syntax contrast comes from weight, foreground intensity, and background
surfaces.  Git and diff faces keep red/green directionality by default.

## Installation

### `use-package` With `:vc`

```elisp
(use-package ivory-themes
  :vc (:url "https://github.com/khzaw/ivory-theme.git"
       :rev :newest)
  :custom
  (ivory-theme-bold-constructs t)
  (ivory-theme-italic-constructs nil)
  :config
  (load-theme 'ivory-light t))
```

### `package-vc-install`

```elisp
(unless (package-installed-p 'ivory-themes)
  (package-vc-install
   '(ivory-themes
     :url "https://github.com/khzaw/ivory-theme.git"
     :branch "master")))

(load-theme 'ivory-light t)
```

### Straight.el

```elisp
(use-package ivory-themes
  :straight (:type git
             :host github
             :repo "khzaw/ivory-theme")
  :custom
  (ivory-theme-bold-constructs t)
  (ivory-theme-italic-constructs nil)
  :config
  (load-theme 'ivory-dark t))
```

### Elpaca

```elisp
(use-package ivory-themes
  :elpaca (:host github
           :repo "khzaw/ivory-theme")
  :custom
  (ivory-theme-bold-constructs t)
  (ivory-theme-italic-constructs nil)
  :config
  (load-theme 'ivory-light t))
```

## Usage

Load a specific variant:

```elisp
(load-theme 'ivory-light t)
(load-theme 'ivory-dark t)
```

Or use the helper commands:

```elisp
(ivory-theme-load 'ivory-light)
(ivory-theme-toggle)
```

## Options

Set options before loading or reloading a theme.

```elisp
(setq ivory-theme-bold-constructs t
      ivory-theme-italic-constructs nil)
```

## Palette Overrides

Diff colors are regular palette entries, so they can be tuned without editing
the face definitions.

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
