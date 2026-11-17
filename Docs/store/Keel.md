# Keel

Shared libraries for WoW Forever addons. Keel adds nothing to your screen on its own; install it because another addon asks for it, such as RenderTuner or Stickies.

## For players

- Extract into `_forever_\Interface\AddOns` so you get `AddOns\Keel\Keel.toc`, then restart the game.
- `/keel theme` picks the look that addons built on Keel share: **Forever** (the game's own look, the default), **Navy** or **Paper**.
- `/keel` lists the other commands, including a gallery of the widgets and a profile of what each addon costs.

## For addon authors

Thirteen small LibStub libraries, each usable alone, fetched with `LibStub("LibKeel<Name>-1.0")`:

- **Util, Test, JSON**: pure helpers, a case runner that works headless and in game, and a JSON reader and writer.
- **Env, Restrict**: what this client offers, CPU and memory profiling, and safe reads of values the client hides in combat.
- **Store, Console**: saved variables with defaults, schema and migrations, plus printing and slash commands.
- **Theme, Widgets**: themed panels, buttons, sliders, lists, tabs, menus and more, drawn without Blizzard templates.
- **Chat, Comm, Group, Secure**: rate-limited chat and addon messages, the group roster, and secure buttons.

Built for interface 16001, bottom-up, with every client call confirmed on this client first.

Source and full documentation: https://github.com/terin678/wow-forever-addons
