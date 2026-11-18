---
name: wow-addon-dev
description: Work on a WoW Forever addon in this repo - edit Lua under AddonProjects/forever/<Addon>, extend the Keel libraries, deploy to the game client, run the headless cases, bump versions, package a zip, and update the addon's guide. Use for any request about a WoW addon, Lua UI frames, TOC files, saved variables, console variables or the Keel libraries.
---

# WoW Forever addon development

Everything here targets WoW Forever: interface 16001, client folder `_forever_`
(`scripts/flavors.psd1` holds the mapping). Addons are built on the library addon Keel.

## Before editing

1. Read `CODING_STANDARDS.md`, `Docs/forever/VISION.md` and the addon's guide in
   `Docs/<Addon>.md`. `Docs/Keel.md` lists every library and what it offers.
2. Find the addon at `AddonProjects/forever/<Addon>/`.
3. Check whether the game folder links to the repo:
   `Get-ChildItem "<WowRoot>\_forever_\Interface\AddOns" | Select Name, LinkType, Target`.
   A real folder where a junction should be means an addon manager replaced it and the
   client is running a published copy; move it aside and run
   `scripts/deploy.ps1 -Flavor forever -Addon <Addon>`.
4. `git status` first. A manager that replaces a junction can also delete files in the
   working tree through it.

## Shared code: Keel

Code more than one addon needs lives in `AddonProjects/forever/Keel` as LibStub libraries
named `LibKeel<Name>-1.0`: Util, Test, JSON, Env, Restrict, Group, Store, Console, Chat,
Comm, Theme, Widgets, Secure. Addons list `## Dependencies: Keel` in their `.toc` and fetch
a library with `LibStub("LibKeelWidgets-1.0")`.

- Add the layer the work needs to Keel, with cases, then compose. A library is added when
  an addon needs it and not before, and it never knows which addon is using it.
- Bump a library's MINOR when its API changes and record the new number in the Contents
  table of `Docs/Keel.md`; `lint.py` fails when the two disagree.
- Do not copy library files into an addon's own folder. `scripts/package.ps1` bundles Keel
  into a zip (not with `-NoDeps`, which is what a store upload wants) and
  `scripts/deploy.ps1` links it.

## Starting a new addon

There is no template yet. Copy the shape of `AddonProjects/forever/Stickies` by hand: the
`.toc`, a `Core.lua` that registers with the store and the console, a pure model file, a UI
file, and `Tests.lua` last. Add a row to `AddonProjects/forever/README.md`, a guide in
`Docs/`, and the addon to `Published` in `scripts/flavors.psd1` when it ships.

## While editing

- New file: add it to the `.toc` in load order (data and logic before UI).
- `Bindings.xml` ships but is never listed in the `.toc`: the client loads it by filename,
  and listing it loads every binding twice. The linter fails on it.
- New client call: confirm it exists on this client first, with the probe (`/keel probe`,
  `/tuner probe`) or by grepping the exported source in
  `_classic_beta_\BlizzardInterfaceCode`. Record what is confirmed in
  `Docs/client-reference.md`. Prefer the client's current mechanism (Addon Compartment,
  `MenuUtil`, the Settings panel, `C_` namespaces) to a legacy one.
- New wait on the client: give it a state, a timeout, and a cancel path.
- New command: a row in `HELP` and a function in `COMMANDS` in `Core.lua`, and a row in
  `Docs/<Addon>.md`.
- New saved field: default it in the `defaults` given to `Store.Register`. A shape change
  is a `migrations` step keyed by the schema it upgrades from, with `schema` bumped.
- Editing a `.toc` needs a client restart. `/reload` does not re-read it, and a client that
  has been running across `.toc` edits can hand back an empty account table (`info.lost`).
  Restart the client before reading a line of addon code.
- New or edited window: follow "Window layout" in `CODING_STANDARDS.md` and build it from
  `LibKeelWidgets-1.0`. Colours come from theme roles, never literal numbers, and the
  window has to read on every theme that ships.
- After editing any UI file, run the `wow-ui-reviewer` agent on it before packaging.
- Read `client-api.md` next to this file before calling into the client. Add to it whenever
  the game teaches you something new.
- A function written inside a constructor cannot see the local being assigned:
  `local t = W.List(page, { onClick = function() t:... end })` reads a nil global,
  because `t` only exists after the assignment finishes. Declare it on its own line first.
- Do not use a Bash heredoc for multi-line Lua edits on this machine; it eats backslashes.
  Write a small Python script to a scratch file and run it, or use the Edit tool.

## Verifying

Four things, in order:

1. `python scripts/lint.py`. It parses every file and catches the mistakes that have
   shipped: a local referenced inside its own assignment, a texture path that does not
   resolve, a `.toc` out of step with the files on disk, a version that moved in one of its
   three places but not the others, a library MINOR the doc does not record, saved
   variables not booted through the store, `Bindings.xml` listed in a `.toc`, and a quoted
   string that runs past the end of its line.
2. `scripts/run-tests.ps1 -Flavor forever -Addon <Addon>`: the addon's cases under LuaJIT
   against a stub client (`scripts/test-harness.lua`). It loads the addon's
   `## Dependencies`, then its `.toc` in order, delivers ADDON_LOADED so the store boots
   `ns.db`, and runs `ns.Tests.Run()`. A file that calls an unstubbed client function at
   file scope fails here by name, which is the standard being enforced; a case that needs
   real widgets returns early on `KEEL_HEADLESS`. Runs in a second.
3. The same cases in game: `/keel test`, `/sticky test`, `/tuner test`. Any decision worth
   arguing about belongs in a pure function with a case, and a case that asserts an
   ordering must have that ordering worked out rather than assumed.
4. The `wow-ui-reviewer` agent on every UI file touched.

Then say plainly in the summary that nothing was run in the client, and give the player the
in-game steps: restart or `/reload`, the commands to run, and to check for Lua errors.
Prefer changes that fail loudly in chat over ones that fail silently.

## Releasing

`Docs/releasing.md` has the steps. In short:

1. Bump `## Version:` in the `.toc`, `local VERSION` in `Core.lua` and the row in
   `AddonProjects/forever/README.md` to the same value.
2. Commit on the feature branch with an imperative subject and a body listing
   player-visible changes. Nothing is pushed until the user has tested in game.
3. `main` only accepts pull requests: `gh pr create`, then `gh pr merge --merge`. Never
   squash: each commit is written to stand on its own so a single change can be found and
   reverted on its own.
4. A release is a tag on `main` (`rendertuner-v<version>` or `keel-v<version>`), whose message is the changelog;
   the workflow publishes it.
