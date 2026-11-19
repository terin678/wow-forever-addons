# WoW Forever addons

Target interface: 16001 (product `wow_classic_beta`, version 1.60.1). Client folder
`_forever_` (the beta was `_classic_beta_`); `scripts/flavors.psd1` is where that changes.

| Addon | Version | Guide |
| --- | --- | --- |
| Keel | 1.0.0 | [Docs/Keel.md](../../Docs/Keel.md) |
| Stickies | 0.1.1 | [Docs/Stickies.md](../../Docs/Stickies.md) |
| RenderTuner | 0.7.1 | [Docs/RenderTuner.md](../../Docs/RenderTuner.md) |

`Keel` is the library addon for this flavor. Addons here list it under `## Dependencies`,
so it must be installed alongside them; `scripts/package.ps1` bundles it into their zips
and `scripts/deploy.ps1` links it into the game folder with them.

The code base is built bottom-up, one layer at a time, and nothing is added until the layers it needs exist: see
[Docs/forever/VISION.md](../../Docs/forever/VISION.md) before adding anything here.
