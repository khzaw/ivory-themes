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

When using a local clone directly, add the directory to both `load-path` and
`custom-theme-load-path` before calling `load-theme`.

```elisp
(add-to-list 'load-path "/path/to/ivory-themes")
(add-to-list 'custom-theme-load-path "/path/to/ivory-themes")
(require 'ivory-themes)
(load-theme 'ivory-light t)
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
      ivory-themes-italic-constructs nil
      ivory-themes-soft-backgrounds nil)
```

## Palette System

Ivory builds its monochrome colors from semantic roles over an 8-bit grayscale
ladder.  In the source palette specs, `(gray 17)` resolves to `#111111`,
`(gray 138)` resolves to `#8a8a8a`, and `(gray 255)` resolves to `#ffffff`.
This keeps visual tuning deliberate: moving a role from `(gray 138)` to
`(gray 146)` makes it one measured step lighter.

The default editor backgrounds use the absolute endpoints: `ivory-light`
anchors `bg` at `(gray 255)`, and `ivory-dark` anchors `bg` at `(gray 0)`.
Adjacent background surfaces keep a small contrast separation from the base
background, so `bg-alt`, `bg-subtle`, and inactive modelines stay visible while
the editor still reads as white or black.

Set `ivory-themes-soft-backgrounds` before loading or reloading a theme to use
near-endpoint backgrounds instead: `ivory-light` uses `#f8f8f8`, and
`ivory-dark` uses `#080808`.

```elisp
(setq ivory-themes-soft-backgrounds t)
(ivory-themes-load 'ivory-light)
```

Readable foreground roles target at least a 3:1 contrast ratio against `bg`.
Primary code text is much higher; the 3:1 floor is for secondary readable text
such as comments, dimmed labels, completion annotations, and inactive UI text.

The public override API remains semantic.  Configure roles such as
`fg-comment`, `bg-block`, or `modeline-accent`; the internal grayscale notation
is only there to keep the base palette systematic.

Palette roles:

| Group | Roles |
| --- | --- |
| Backgrounds | `bg`, `bg-alt`, `bg-dim`, `bg-active`, `bg-subtle`, `bg-block`, `bg-hl`, `bg-region`, `bg-search`, `bg-modeline`, `bg-modeline-inactive` |
| Foregrounds | `fg`, `fg-alt`, `fg-dim`, `fg-faint`, `fg-name`, `fg-syntax`, `fg-string`, `fg-comment`, `fg-comment-delimiter`, `fg-inactive` |
| UI structure | `border`, `cursor`, `modeline-accent` |
| Accents and ANSI roles | `red`, `red-faint`, `green`, `green-faint`, `yellow`, `blue` |
| Diff backgrounds | `bg-added`, `bg-added-faint`, `bg-removed`, `bg-removed-faint`, `bg-changed`, `bg-changed-faint` |
| Diff foregrounds | `fg-added`, `fg-added-intense`, `fg-removed`, `fg-removed-intense`, `fg-changed`, `fg-changed-intense` |

## Palette Overrides

Palette entries can be overridden from user configuration before loading or
reloading a theme.  The override names are the same symbols used in
`ivory-themes-palettes`.  Override values must be six-digit `#rrggbb` hex
colors.  Unknown role names signal an error instead of being ignored.

For example, tune light comments:

```elisp
(setq ivory-themes-light-palette-overrides
      '((fg-comment . "#8a8a8a")
        (fg-comment-delimiter . "#929292")))

(ivory-themes-load 'ivory-light)
```

Or make diff backgrounds stronger:

```elisp
(setq ivory-themes-light-palette-overrides
      '((bg-added . "#d5f5df")
        (bg-removed . "#ffe0de")))

(ivory-themes-load 'ivory-light)
```

Shared overrides go in `ivory-themes-common-palette-overrides`; variant-specific
overrides go in `ivory-themes-light-palette-overrides` or
`ivory-themes-dark-palette-overrides`.

## License

Ivory Themes is licensed under the MIT License.  See [LICENSE](LICENSE).
