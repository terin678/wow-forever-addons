# Releasing RenderTuner

Pushing a tag publishes RenderTuner, zipped with ICKit, to GitHub, CurseForge and Wago.
The workflow is `.github/workflows/release-rendertuner.yml`. It stops before publishing if
the tag and `RenderTuner.toc` disagree, or if lint or a test fails.

## To release

1. Bump the version in `RenderTuner.toc`, `Core.lua` and the README row; merge to `main`.
2. Tag the merge. The tag's message is the changelog, in markdown:

   ```bash
   git tag -a rendertuner-v0.4.1 -m "Fixes the light range note. Adds ..."
   git push origin rendertuner-v0.4.1
   ```

## One-time setup (repo Settings, Secrets and variables, Actions)

| Name | Kind | Where it comes from |
| --- | --- | --- |
| `CF_API_TOKEN` | secret | CurseForge, the authors site, API Tokens |
| `CF_PROJECT_ID` | variable | The number in "About Project" on the CurseForge page |
| `CF_GAME_VERSION_IDS` | variable | The id of the Forever game version. Leave it empty on the first tag: the job lists the candidates from CurseForge and stops |
| `WAGO_API_TOKEN` | secret | Wago developer portal, API keys |
| `WAGO_PROJECT_ID` | variable | The project's id on the Wago developer dashboard |

A site whose token or project id is not set is skipped, so Wago can be added later. The
GitHub release always happens.

Wago's metadata key for Forever, `supported_forever_patch`, is inferred from its other
flavors and its list of game versions; if Wago refuses the upload, its API docs have the name.
