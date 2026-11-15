# Graphite

A neutral theme for [Home Assistant](https://www.home-assistant.io): light greys on a
near-white canvas, raised cards on a near-black one, blue as the only accent. Light and dark
in one file, so the theme follows whichever mode you or your device has set.

<!-- ha-marketplace:exclude-start -->

## Install

[![Open your Home Assistant instance and open this repository inside the Marketplace.](https://my.home-assistant.io/badges/hacs_repository.svg)](https://my.home-assistant.io/redirect/hacs_repository/?owner=psym88&repository=ha_theme_graphite&category=theme)

Home Assistant reads themes from the `themes` folder of your configuration. That line is in
`configuration.yaml` on every recent install, and Home Assistant adds it itself when it
creates the file:

```yaml
frontend:
  themes: !include_dir_merge_named themes
```

### From the Marketplace (or HACS before 2026.11)

1. Open **Settings → Marketplace**, search for **Graphite**, install it. The badge above
   opens this repository there directly.
2. Home Assistant reloads the themes. If the theme is not in the list yet, run the
   `frontend.reload_themes` action under **Settings → Developer tools → Actions**.
3. Select **Graphite** in your profile, under **Appearance**.

Home Assistant installs the file in `themes/graphite/` of your configuration. Nothing else to
set up: no resources, no extra integration.

### By hand

1. Get `themes/graphite.yaml` from this repository.
2. Put it in the `themes` folder next to your `configuration.yaml`.
3. Restart Home Assistant, or run `frontend.reload_themes`, and select the theme in your
   profile.

<!-- ha-marketplace:exclude-end -->

## Light, dark, auto

**Light**, **dark** and **auto** are chosen in Home Assistant, in your profile or in the menu
of the sidebar. Graphite carries a full set of values for both modes and follows that
setting, so a single theme covers a dashboard that should be light at noon and dark at night.

## What it changes, and what it leaves alone

- **Colours.** Nothing else. Card radius, card border, switch shape, dialog radius and fonts
  stay on the Home Assistant defaults, so the theme keeps following the interface when the
  interface changes. The hairline that cards have by default picks up the Graphite border
  colour on its own.
- **Entity icons stay grey.** Inactive icons are neutral, only active things get the accent.
  If you want the Home Assistant habit of blue icons, set
  `state-icon-color: "var(--graphite-accent)"` in your copy of the file.
- **Charts and calendars get 54 series colours**, community cards another 14, all of them
  derived from the five hues of the theme instead of a second colour scheme.

## Colours of your own

Every colour in the theme is a `graphite-*` role at the top of the file, and everything else
points at those roles. So a variation is a handful of lines:

```yaml
Graphite Blue:
  modes:
    light:
      graphite-accent: "#2563eb"
    dark:
      graphite-accent: "#60a5fa"
```

Copy `themes/graphite.yaml`, keep the roles you care about, give the theme a name of its own.
Do not reuse the name `Graphite` in a second file: Home Assistant merges theme files by theme
name, and the last file wins for a name that appears twice, which would drop the rest of the
theme.

## How the file is built

Three layers, in `themes/graphite.yaml`:

1. **`graphite-*` roles** — canvas, card, borders, text, the five hues, the quiet tints. The
   only layer you edit.
2. **`ha-color-*` palettes** — the eleven steps per palette that newer components read.
   Derived from the roles.
3. **Semantics, legacy names, component variables** — everything from `color.globals.ts`, the
   dialog, switch, slider, tooltip and codemirror variables. They point at layers one and two.

The semantic layer is written out in full, including values Home Assistant would already get
right: its own dark block would otherwise override some Graphite values.

Because of those `var()` chains, a colour change is usually one line per mode, and the ramps,
the semantics and the legacy names follow on their own.

## Compatibility

Written and tested against the Home Assistant frontend of the 2026.x series
(`20261028.6`). Both the classic variables and the `ha-color-*` design tokens are set, which
is what keeps switches, dialogs, chips and the new pickers from falling back to the default
blue.

Home Assistant makes no promise about theme variables: one can be renamed or dropped in any
release, so a surface that looked fine can come back wrong after an update. Fixing it is a
matter of pointing that variable at a Graphite role again.

Released under the [MIT license](LICENSE).
