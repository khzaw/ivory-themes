# Ivory Themes

Ivory is a minimal, near-monochromatic Emacs theme package with two variants:

- `ivory-light`
- `ivory-dark`

Most syntax contrast comes from weight, foreground intensity, and background
surfaces.  Git and diff faces keep red/green directionality by default.

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

## Options

Set options before loading or reloading a theme.

```elisp
(setq ivory-themes-bold-constructs t      ; bold weight for syntax/UI contrast
      ivory-themes-italic-constructs nil  ; italics where conventional
      ivory-themes-soft-backgrounds nil)  ; pure white/black editor backgrounds
```

| Option | Default | Effect |
| --- | --- | --- |
| `ivory-themes-bold-constructs` | `t` | Use bold weight to create syntax and UI contrast. |
| `ivory-themes-italic-constructs` | `nil` | Allow italics in faces that conventionally use them. |
| `ivory-themes-soft-backgrounds` | `nil` | Replace the pure white/black editor background with a slightly softened one. |

### Softened backgrounds

By default `ivory-light` uses pure white and `ivory-dark` uses pure black for
the editor background.  Enable `ivory-themes-soft-backgrounds` to take the edge
off that contrast — `ivory-light` shifts to `#f8f8f8` and `ivory-dark` to
`#080808`, along with matching adjustments to adjacent surfaces.

```elisp
(setq ivory-themes-soft-backgrounds t)
(ivory-themes-load 'ivory-light)
```

You can also flip it without restarting Emacs:

```elisp
(ivory-themes-toggle-soft-backgrounds)
```

## Toggling between light and dark

```elisp
(ivory-themes-toggle)
```

## Palette System

Everything that makes Ivory feel cohesive comes from one idea: colors are
defined by *semantic role* over a single 8-bit grayscale ladder, not picked
ad hoc.  In the source palette specs, `(gray 17)` resolves to `#111111`,
`(gray 138)` resolves to `#8a8a8a`, and `(gray 255)` resolves to `#ffffff`.
This keeps visual tuning deliberate: moving a role from `(gray 138)` to
`(gray 146)` makes it exactly one measured step lighter.

Readable foreground roles target at least a 3:1 contrast ratio against `bg`.
Primary code text sits well above that; the 3:1 floor is for secondary readable
text such as comments, dimmed labels, completion annotations, and inactive UI
text.  Working in role-and-step terms is what keeps the whole palette balanced
when any one value changes.

### Softened backgrounds

The default editor backgrounds sit at the absolute endpoints of the ladder:
`ivory-light` anchors `bg` at `(gray 255)` and `ivory-dark` anchors `bg` at
`(gray 0)`.  Adjacent surfaces keep a small contrast separation from that base,
so `bg-alt`, `bg-subtle`, and inactive modelines stay visible while the editor
still reads as white or black.

For a softened look, there are a couple of options available:

- Enable `ivory-themes-soft-backgrounds` (see [Options](#options)) to pull `bg`
  just off the endpoint — `#f8f8f8` for light, `#080808` for dark — with the
  neighbouring surfaces moved to match.
- Override individual background roles yourself (see
  [Palette Overrides](#palette-overrides)) if you want a specific tone.

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

## Screenshots
### Light mode

#### Markdown

![Markdown](.github/screenshots/markdown-light.png)

#### TypeScript

![TypeScript](.github/screenshots/typescript-light.png)

#### Rust

![Rust](.github/screenshots/rust-light.png)

### Dark mode

#### Markdown

![Markdown](.github/screenshots/markdown-dark.png)

#### Go

![Go](.github/screenshots/go-dark.png)

#### Python

![Python](.github/screenshots/python-dark.png)

#### JavaScript

![JavaScript](.github/screenshots/javascript-dark.png)

#### Magit Status

![Magit Status](.github/screenshots/magit-status-dark.png)

#### Magit Log

![Magit Log](.github/screenshots/magit-log-dark.png)

#### Avy

![Avy](.github/screenshots/avy-dark.png)


## License

Ivory Themes is licensed under the MIT License.  See [LICENSE](LICENSE).
