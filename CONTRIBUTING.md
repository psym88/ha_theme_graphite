# Contributing

## Try it locally

1. Copy `themes/graphite.yaml` into the `themes` folder of your Home Assistant configuration.
2. Make sure `configuration.yaml` has `frontend: themes: !include_dir_merge_named themes`.
3. Run the `frontend.reload_themes` action under **Settings → Developer tools → Actions**.
   No restart needed.
4. Select **Graphite** in your profile, and switch the mode there too.

## Where to change what

| You want | Change |
| --- | --- |
| Another colour for cards, canvas, borders, text | the `graphite-*` role, in both modes |
| Another accent | `graphite-accent`, `graphite-accent-hover`, `graphite-accent-pressed`, both modes |
| A component that still shows the default blue | the `ha-color-fill-*` or `ha-color-border-*` token of that component, and point it at a role |
| A colour a community card asks for | the legacy layer (`color.globals.ts` names) |
| Colours in graphs or the calendar | the series section at the bottom |

Four rules keep the file maintainable:

- **Both modes.** Change it in `light`, change it in `dark` too, unless the value is genuinely
  the same in both.
- **Hex only in the roles.** Everything below points at roles through `var()`. A hex in the
  semantic layer is a value the next colour change will miss.
- **Quote every value.** In YAML an unquoted `#f2f3f5` is a comment, and the theme schema of
  Home Assistant only accepts strings.
- **No YAML tags.** `!include` and `!secret` are refused: the Marketplace validates every
  theme it installs, and a tag could pull any file into every user's install.

The comments in `themes/graphite.yaml` say what each role is for; the layering is described in
the README as well.

## Before a pull request

Walk through both modes:

- [ ] a dashboard with tiles, entities, a history chart, weather, a media player
- [ ] more-info dialogs: a sensor, a light with a colour picker, a climate
- [ ] settings pages: the automation editor, the entity list, a device page
- [ ] a form: text input, dropdown, checkbox, switch, slider, date picker
- [ ] energy dashboard (all of the series colours), logbook and history
- [ ] the YAML code editor, and developer tools → template
- [ ] a phone width, 375-430 px: header and sidebar are laid out differently there
- [ ] contrast: text on tints, and text on filled colour surfaces, in both modes
- [ ] the HACS action is green (it runs on every push and pull request)

Screenshots of what changed, light and dark, in the pull request.

## Releases

Releases are cut by hand: tag `vX.Y.Z` on `main`, publish it as a GitHub release, write the
notes as if the reader has to decide whether to update now. Home Assistant and HACS read the
tag as the version, and the body of the release as the release notes. Add the version to
[CHANGELOG.md](CHANGELOG.md) in the same breath.

## Screenshots for the README

[images/README.md](images/README.md) says which two files belong in `images/` and how to take
them. The catalog only accepts a theme repository whose README contains images.
