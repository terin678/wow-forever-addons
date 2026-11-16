# WoW Forever addons

Addons for WoW Forever (client 1.60.1, interface 16001). Download the zips from
[Releases](https://github.com/terin678/wow-forever-addons/releases).

| Addon | What it does | Guide |
| --- | --- | --- |
| [Keel](AddonProjects/forever/Keel) | The shared kit the others build on: Forever theme, widgets, sliders, lists, gallery (`/keel`) | [Docs/Keel.md](Docs/Keel.md) |
| [Stickies](AddonProjects/forever/Stickies) | Notes on the screen, with a minimap and Addon Compartment entry | [Docs/Stickies.md](Docs/Stickies.md) |
| [RenderTuner](AddonProjects/forever/RenderTuner) | A live control for about 160 graphics settings, upscaling and quality presets, search, Auto-set and undo (`/tuner`) | [Docs/RenderTuner.md](Docs/RenderTuner.md) |

## Install

Extract the zips into `_forever_\Interface\AddOns` so you get
`AddOns\Keel\Keel.toc` and so on, then restart the client. Keel is required by the others.

## Working on it

```powershell
python scripts/lint.py
.\scripts\run-tests.ps1 -Flavor forever -Addon RenderTuner   # needs LuaJIT
.\scripts\deploy.ps1 -Flavor forever -Addon RenderTuner      # links it into the game folder
```

[CODING_STANDARDS.md](CODING_STANDARDS.md) and [CLAUDE.md](CLAUDE.md) cover conventions.

Licensed under the GPL 3.0, see [LICENSE](LICENSE).
