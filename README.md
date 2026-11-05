# WoW Forever addons

Addons for WoW Forever (client 1.60.1, interface
16001), made by the guild Impulse Control. Download the zips from
[Releases](https://github.com/terin678/wow-forever-addons/releases).

| Addon | What it does | Guide |
| --- | --- | --- |
| [ICKit](AddonProjects/forever/ICKit) | The shared kit the others build on: Forever theme, widgets, sliders, lists, gallery (`/ickit`) | [Docs/ICKit.md](Docs/ICKit.md) |
| [Stickies](AddonProjects/forever/Stickies) | Notes on the screen, with a minimap and Addon Compartment entry | [Docs/Stickies.md](Docs/Stickies.md) |
| [RenderTuner](AddonProjects/forever/RenderTuner) | A live control for about 140 graphics settings, upscaling and quality presets, search and undo (`/tuner`) | [Docs/RenderTuner.md](Docs/RenderTuner.md) |

## Install

Extract the zips into `_forever_\Interface\AddOns` so you get
`AddOns\ICKit\ICKit.toc` and so on, then restart the client. ICKit is required by the others.

## Working on it

```powershell
python scripts/lint.py
.\scripts\run-tests.ps1 -Flavor forever -Addon RenderTuner   # needs LuaJIT
.\scripts\deploy.ps1 -Flavor forever -Addon RenderTuner      # links it into the game folder
```

[CODING_STANDARDS.md](CODING_STANDARDS.md) and [CLAUDE.md](CLAUDE.md) cover conventions.
The history of these files before this repo is in
[terin678/ic-addons](https://github.com/terin678/ic-addons), where they grew out of the
Anniversary addons.

Licensed under the GPL 3.0, see [LICENSE](LICENSE).
