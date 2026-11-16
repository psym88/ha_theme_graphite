# Repository instructions

- Use English for all comments, documentation, release notes and commit messages.
- The theme is `themes/graphite.yaml`, edited directly. It carries a full set of values for light and dark in one file, and it stays on the Home Assistant defaults for everything that is not a colour: no radius, no fonts, no switch shapes.
- The top level key of the theme and `name` in `hacs.json` are the same word, and `filename` in `hacs.json` is the file below `themes/`. Run `node scripts/check-theme.mjs` before committing; it also wants the Marketplace link in `README.md` to point at the published repository.
- Keep `README.md` free of screenshots: the Marketplace page is the picture a theme gets, and an image in the README has to be kept in step with the theme forever.

## Where this theme lives

- The repository is developed on `https://git.itup.ch/mme/ha_theme_graphite`. `https://github.com/psym88/ha_theme_graphite` is the published copy the Home Assistant Marketplace reads.
- Publishing is a release on Forgejo: `.forgejo/workflows/sync-github.yml` pushes the branch, every tag, the release and `graphite.yaml` as that release's downloadable asset to GitHub. A manual run of the same workflow without a tag only syncs branch and tags.
- GitHub gets only the file Home Assistant installs and the page a visitor reads: the branch and every new tag are published from the include list `PUBLISH_INCLUDE` in the workflow, `hacs.json README.md LICENSE images`, plus the file `hacs.json` names, which for a theme is the one below `themes/`. A new file here is not on GitHub until it is named on that list, and `AGENTS.md`, `scripts/` and `.gitignore` are not. The branch tip on GitHub is a commit of its own with the commit here as its parent, so its sha is not the sha here, and that is the design rather than a mistake. Older tags keep whatever they were published with: they never move.
- Never commit to the GitHub repository, and never move or delete a tag or a release asset that is already on GitHub: the Marketplace installs from them, and the download count hangs off the asset, so replacing it starts that count at zero.
- Versions are dated, `20261115.2` was the second release of 15 November 2026. A published tag never moves: a new version is a new tag.
