# wow-forever-addons

Impulse Control's addons for WoW Forever (interface 16001, client folder `_classic_beta_`).
Read `CODING_STANDARDS.md` before changing any Lua, and `Docs/forever/VISION.md` before
adding anything: this is built bottom-up, one layer at a time.

## Where things are

- Addons: `AddonProjects/forever/<AddonName>/`. The addon folder is exactly what ships.
  `ICKit` is the library addon the others depend on.
- User docs: `Docs/<AddonName>.md`. Update it whenever a command or panel changes.
- What the client has been proven to do: `Docs/client-reference.md`.
- Scripts: `scripts/deploy.ps1` (link an addon into the game folder), `scripts/package.ps1`
  (zip it), `scripts/run-tests.ps1` (headless cases), `scripts/lint.py`. Flavor table:
  `scripts/flavors.psd1`.
- Skill for addon work: `.claude/skills/wow-addon-dev/SKILL.md` and `client-api.md`. Its
  examples come from the Anniversary addons this code base grew out of (the repo
  terin678/ic-addons); the client rules in it still apply.

## Git workflow

- Never commit on `main`; work on `feature/<topic>` or `fix/<topic>` and open a PR.
- Merge with a merge commit, never a squash: each commit is written to stand on its own.
- Never commit `WTF/`, saved variables, or zips. Releases attach zips from `dist/`.

## Rules that matter most

- No client API is used until it is confirmed on this client (the in-game probe or the
  exported source). Record what is confirmed in `Docs/client-reference.md`.
- Modern first: where the client has a current mechanism and a legacy one, use the current
  one. Grep `_classic_beta_\BlizzardInterfaceCode` for how the client does it.
- Layers depend downward only; a library is added when an addon needs it.
- Client API calls that wait on the game must have timeouts and a cancel path.
- Bump the version in the `.toc`, the `Core.lua` load message and the row in
  `AddonProjects/forever/README.md` together. `lint.py` fails on any two disagreeing.
- Editing a `.toc` needs a client restart. `/reload` does not re-read it.

## Verifying changes

1. `python scripts/lint.py`.
2. `scripts/run-tests.ps1 -Flavor forever -Addon <Addon>`: the addon's cases under LuaJIT
   against a stub client. A case that needs real widgets returns early on `IC_HEADLESS`.
3. The same cases in game: `/ickit test`, `/stickies test`, `/tuner test`.
4. The `wow-ui-reviewer` agent on every UI file touched.

Then deploy, restart or `/reload`, run the commands, check BugSack. Say plainly when
in-game checks were not run.
