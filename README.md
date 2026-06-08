# Ivory Themes

Ivory is a minimal, near-monochromatic Emacs theme package with two variants:

- `ivory-light`
- `ivory-dark`

Most syntax contrast comes from weight, foreground intensity, and background
surfaces.  Git and diff faces keep red/green directionality by default.

## Naming

The package, Lisp feature, and GitHub repository are `ivory-themes`, because
the package ships more than one theme.  The theme names are `ivory-light` and
`ivory-dark`.

## Installation

### `use-package` With `:vc`

```elisp
(use-package ivory-themes
  :vc (:url "https://github.com/khzaw/ivory-themes.git"
       :rev :newest)
  :custom
  (ivory-themes-bold-constructs t)
  (ivory-themes-italic-constructs nil)
  :config
  (load-theme 'ivory-light t))
```

### `package-vc-install`

```elisp
(unless (package-installed-p 'ivory-themes)
  (package-vc-install
   '(ivory-themes
     :url "https://github.com/khzaw/ivory-themes.git"
     :branch "master")))

(load-theme 'ivory-light t)
```

### Straight.el

```elisp
(use-package ivory-themes
  :straight (:type git
             :host github
             :repo "khzaw/ivory-themes")
  :custom
  (ivory-themes-bold-constructs t)
  (ivory-themes-italic-constructs nil)
  :config
  (load-theme 'ivory-dark t))
```

### Elpaca

```elisp
(use-package ivory-themes
  :elpaca (:host github
           :repo "khzaw/ivory-themes")
  :custom
  (ivory-themes-bold-constructs t)
  (ivory-themes-italic-constructs nil)
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
(ivory-themes-load 'ivory-light)
(ivory-themes-toggle)
```

## Options

Set options before loading or reloading a theme.

```elisp
(setq ivory-themes-bold-constructs t
      ivory-themes-italic-constructs nil)
```

## Palette Overrides

Diff colors are regular palette entries, so they can be tuned without editing
the face definitions.  The active mode-line accent is also configurable through
the `modeline-accent` palette entry.

```elisp
(setq ivory-themes-light-palette-overrides
      '((bg-added . "#d5f5df")
        (bg-removed . "#ffe0de")
        (fg-added . "#005a00")
        (fg-removed . "#990f0f")))
```

Shared overrides go in `ivory-themes-common-palette-overrides`; variant-specific
overrides go in `ivory-themes-light-palette-overrides` or
`ivory-themes-dark-palette-overrides`.
