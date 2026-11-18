# Releasing

Pushing a tag publishes one addon to GitHub, CurseForge and Wago. The workflow is
`.github/workflows/release.yml`. It stops before publishing if the tag and the addon's
`.toc` disagree, or if lint or a test fails.

| Tag | Publishes | In the zip |
| --- | --- | --- |
| `rendertuner-v<version>` | RenderTuner | RenderTuner and Keel, or RenderTuner alone once `KEEL_CF_SLUG` is set |
| `keel-v<version>` | Keel | Keel |

## To release

1. Bump the version in the addon's `.toc`, its `Core.lua` and the README row; merge to `main`.
2. Tag the merge. The tag's message is the changelog, in markdown:

   ```bash
   git tag -a rendertuner-v0.4.1 -m "Fixes the light range note. Adds ..."
   git push origin rendertuner-v0.4.1
   ```

## Alpha and beta

A version with `-alpha` or `-beta` in it is published as that: release type alpha or beta
on CurseForge, stability alpha or beta on Wago, a pre-release on GitHub. The store apps
offer those only to players who have asked for that channel, so nobody's install changes
under them. The whole version, suffix included, goes in the `.toc`, `Core.lua` and the
README row, and in the tag:

   ```bash
   git tag -a keel-v0.15.0-beta.1 -m "First release of Keel as a project of its own."
   git push origin keel-v0.15.0-beta.1
   ```

The stable release is the same code with the suffix taken off and a new tag.

## Keel as a project of its own

RenderTuner's zip carries Keel until the variable `KEEL_CF_SLUG` is set. From then on it
ships alone and names Keel as a required dependency on CurseForge; on Wago the dependency
is set by hand on RenderTuner's project page. The order that breaks nobody:

1. Create Keel's projects on both stores; set `KEEL_CF_PROJECT_ID` and `KEEL_WAGO_PROJECT_ID`.
2. Release Keel as a beta (`keel-v<version>-beta.1`) and install it from each store app.
3. Set `KEEL_CF_SLUG`, and release RenderTuner as a beta. Check that a clean install from
   each app brings Keel with it.
4. Release Keel stable, and only then RenderTuner stable. A stable RenderTuner without Keel
   in it, while Keel is still a beta, loads for nobody on the stable channel.

If a release gets part of the way (GitHub done, a store refused), mend what was wrong on
`main` and publish the same tag again, without moving it:

   ```bash
   gh workflow run release.yml --ref main -f tag=rendertuner-v0.4.1
   ```

Add `-f curseforge=false` or `-f wago=false` to leave out a store that already has the file.

## The store pages

The descriptions on CurseForge and Wago are `Docs/store/RenderTuner.md` and
`Docs/store/Keel.md`, kept here so they have a history. Neither store's upload API takes a
description or screenshots, so both are pasted and uploaded by hand on each site when they
change. Screenshots must be under 2 MB: crop to the panel and what is around it, which loses
nothing, before reaching for compression.

## One-time setup (repo Settings, Secrets and variables, Actions)

| Name | Kind | Where it comes from |
| --- | --- | --- |
| `CF_API_TOKEN` | secret | CurseForge, the authors site, API Tokens |
| `WAGO_API_TOKEN` | secret | Wago developer portal, API keys |
| `CF_PROJECT_ID` | variable | RenderTuner: the number in "About Project" on its CurseForge page |
| `WAGO_PROJECT_ID` | variable | RenderTuner: the project's id on the Wago developer dashboard |
| `KEEL_CF_PROJECT_ID` | variable | Keel: the same number on its CurseForge page |
| `KEEL_WAGO_PROJECT_ID` | variable | Keel: the same id on the Wago developer dashboard |
| `KEEL_CF_SLUG` | variable | Keel: the last part of its CurseForge page's address. Setting it takes Keel out of RenderTuner's zip; see above |
| `CF_GAME_VERSION_IDS` | variable | Optional. CurseForge ids to use instead of looking up the game version named 1.60.1 (set `CF_GAME_VERSION` to look up another name) |

A store whose token is not set, or an addon whose project id for that store is not set, is
skipped, so a store can be added later. The GitHub release always happens.

Wago's metadata key for Forever, `supported_forever_patch`, is inferred from its other
flavors and its list of game versions; if Wago refuses the upload, its API docs have the name.
