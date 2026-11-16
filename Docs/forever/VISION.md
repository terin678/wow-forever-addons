# WoW Forever addons: vision

What the Forever line is for, the rules it is built by, and the order things arrive in.
Read this before adding anything under `AddonProjects/forever`.

## Why a fresh start

The Anniversary addons grew on a legacy client (interface 20506) and their shared library,
ICLibs, grew with them: one large `Core:Attach`, one large UI toolkit, both written for
that client's frames and templates. WoW Forever (interface 16001) runs on the modern client
base. Carrying the whole library across would mean building on assumptions nobody has
checked. So Forever starts at the bottom: small pure helpers first, then one layer at a
time, each proven on the new client before anything stands on it. Nothing is ported until
the layers it needs exist.

## Principles

1. **Small addons, one job each.** Every addon is useful alone and needs only the kit.
2. **Layers depend downward only.** Helpers and the test runner at the bottom; then what
   the client offers, saved variables, the console and themes; then widgets; then addons.
   Nothing reaches up, and a library never knows which addon is using it.
3. **Pure logic is separate from frames.** A model function takes its tables as arguments
   and returns a result, so it has a headless case. Frames only draw what the model says.
4. **Modern first.** Where the client offers a current mechanism and a legacy one, use
   the current one: the Addon Compartment, `MenuUtil`, the Settings panel, the `C_`
   namespaces. On this client the new path is the one most likely to exist and to keep
   working. A legacy extra beside it is fine when players expect it.
5. **Client facts are probed, never assumed.** No API is used until the in-game probe or
   exported interface source confirms it exists on this client. What is confirmed is
   written to [client-reference.md](../client-reference.md).
6. **General audience.** Neutral names, no guild assumptions in behaviour, and every
   surface is themeable. The default theme is the game's own look; nothing that ships
   carries anyone's name or mark.
7. **Data from day one.** Account and character tables, a schema number and migrations
   exist in the first version of every addon, so the second version never has to guess
   what the first one saved.
8. **Idle means zero work.** No `OnUpdate` when idle, no polling. Profiling is part of the
   kit, so "is this addon costing frames" is one command rather than an investigation.
9. **No ports until the layer below exists.** A port arrives as a composition of layers
   that are already proven, not as a copy of an Anniversary folder.

## The layers

| Layer | Library | What it is | State |
| --- | --- | --- | --- |
| 0 | `LibKeelUtil-1.0` | Pure helpers: text, tables, lists | shipped in Keel 0.1.0 |
| 0 | `LibKeelTest-1.0` | The case runner, headless and in game | shipped in Keel 0.1.0 |
| 1 | `LibKeelEnv-1.0` | What this client offers: build, feature probe, CPU and memory | shipped in Keel 0.2.0 |
| 1 | `LibKeelStore-1.0` | Saved variables: defaults, schema, migrations, the load check | shipped in Keel 0.2.0 |
| 1 | `LibKeelConsole-1.0` | Printing and slash commands | shipped in Keel 0.2.0 |
| 1 | `LibKeelTheme-1.0` | The theme registry: colour and font roles, change listeners | shipped in Keel 0.3.0 |
| 2 | `LibKeelWidgets-1.0` | Themed frames: panel, label, button, check box, edit box, tooltip, menu, confirm | shipped in Keel 0.3.0 |

All of them live in one library addon, [Keel](../Keel.md). A library is added when an
addon needs it and not before.

## Roadmap

1. **Kit base.** The flavor in the repo, Keel with layer 0, the headless harness and lint
   knowing about it. *(done: Keel 0.1.0)*
2. **Layer 1 and the probe.** `/keel probe` records what this client offers into the
   kit's saved variables, and `/keel profile` reports CPU and memory. The findings decide
   how the widgets are drawn. *(done: Keel 0.2.0; the findings are in [client-reference.md](../client-reference.md))*
3. **Themes and widgets.** The smallest set the first addon needs, with a gallery command.
   *(built: Keel 0.3.0)*
4. **Stickies.** The first addon: small draggable notes that stay on screen, each a title
   and a checklist. A note belongs to one character or to the whole account.
   *(built: Stickies 0.1.0)*
5. **A Forever addon template,** cut from Stickies once it works, so the next addon starts
   from something real.

After that, in rough order and only as someone wants them: reminders and timers on notes,
lists shared between players, and then the trade and auction tools as compositions of the
layers rather than ports.

## What stays the same as the rest of the repo

Branches and pull requests, never a commit on `main`. The version in three places. Cases
that run headless before the client is opened and again in game. A client restart after
any `.toc` change. `Bindings.xml` never listed in a `.toc`. See `CODING_STANDARDS.md`.
