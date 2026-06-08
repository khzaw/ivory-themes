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

## Palette System

Ivory builds its monochrome colors from semantic roles over an 8-bit grayscale
ladder.  In the source palette specs, `(gray 17)` resolves to `#111111`,
`(gray 153)` resolves to `#999999`, and `(gray 255)` resolves to `#ffffff`.
This keeps visual tuning deliberate: moving a role from `(gray 153)` to
`(gray 166)` makes it one measured step lighter.

The public override API remains semantic.  Configure roles such as
`fg-comment`, `bg-block`, or `modeline-accent`; the internal grayscale notation
is only there to keep the base palette systematic.

## Palette Overrides

Palette entries can be overridden from user configuration before loading or
reloading a theme.  The override names are the same symbols used in
`ivory-themes-palettes`, such as `fg`, `fg-comment`, `bg-modeline`,
`modeline-accent`, `fg-name`, `fg-syntax`, `bg-added`, or `fg-removed`.

For example, tune light comments:

```elisp
(setq ivory-themes-light-palette-overrides
      '((fg-comment . "#969696")
        (fg-comment-delimiter . "#c0c0c0")))
```

Or make diff backgrounds stronger:

```elisp
(setq ivory-themes-light-palette-overrides
      '((bg-added . "#d5f5df")
        (bg-removed . "#ffe0de")))
```

Shared overrides go in `ivory-themes-common-palette-overrides`; variant-specific
overrides go in `ivory-themes-light-palette-overrides` or
`ivory-themes-dark-palette-overrides`.

## License

Ivory Themes is licensed under the MIT License.  See [LICENSE](LICENSE).
