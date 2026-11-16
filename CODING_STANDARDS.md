# Coding standards

These apply to every addon in this repo, so that anyone can open any addon here and find
the same shape. They are written for WoW Forever (interface 16001) and for addons built on
the library addon Keel. `Docs/forever/VISION.md` says why the code is layered as it is;
`Docs/Keel.md` documents every library named below.

## Layout of an addon

```
AddonName/
  AddonName.toc        Interface, Title, Notes, Author, Version, IconTexture, Category,
                       SavedVariables, Dependencies, then the file list
  Bindings.xml         Key bindings, if any. Shipped but NEVER listed in the .toc
  Core.lua             Version, the saved tables, this addon's commands and events
  <Model>.lua          The logic: pure functions over tables (Notes.lua, Model.lua)
  <Client>.lua         The one file that calls the client, where there is much of it
                       (RenderTuner's Apply.lua)
  UI.lua, Panel.lua    Frames, drawn from what the model says
  Tests.lua            Loaded last, so every module exists when its cases register
```

- The `.toc` file list is load order. Data and logic files load before UI files.
- **Pure logic is separate from frames.** A model function takes its tables as arguments and
  returns a result, so it has a headless case. Frames only draw what the model says.
- A decision that has a side effect is two functions: one that decides and returns a plan,
  pure, and one that performs it. `LibKeelChat-1.0` is the shape: `Chat.Decide` is what the
  cases read, and the sender is the only place a line is sent.
- `Bindings.xml` is loaded by the client by filename. Listing it in the `.toc` loads every
  binding twice; `scripts/lint.py` fails on it.
- An addon names its own heading in the AddOns list with `## Category:`, by what it is for
  and not by who made it: RenderTuner says `Graphics`, Stickies `Notes`, Keel `Libraries`.
  None of them uses `## Group:`, which nests an addon under another; its value has to be an
  addon that exists, and a made-up name silently ungroups everything using it.
  `Docs/client-reference.md` has the whole model.
- Nothing an addon shows a player carries a person's, a guild's or a server's name or mark.
  Names are for what a thing does.
- Only the addon folder ships. No README, screenshots, or scripts inside it.
- **No globals.** Every file starts with `local addonName, ns = ...` and hangs what it
  exports off `ns`, which the client gives each addon privately. A module claims its own
  table idempotently: `ns.Model = ns.Model or {}` then `local Model = ns.Model`. The only
  intentional globals are the saved-variable tables named in the `.toc`, frames that must
  be named for `UISpecialFrames` or a template, and the `BINDING_*` strings and functions
  `Bindings.xml` calls by name.
- The plumbing every addon shares comes from Keel, fetched with LibStub at the top of
  `Core.lua`: `LibKeelStore-1.0` boots the saved tables, `LibKeelConsole-1.0` prints and
  dispatches slash commands, `LibKeelTest-1.0` runs the cases, `LibKeelEnv-1.0` wraps
  handlers so their cost can be seen, `LibKeelUtil-1.0` holds the pure helpers. An addon
  carries none of that itself. `Stickies/Core.lua` is the worked example of an addon, and
  `Keel/Gallery.lua` of a window.
- Layers depend downward only. A library never knows which addon is using it, and a library
  is added to Keel when an addon needs it and not before.

## Lua style

- Four-space indentation. No tabs.
- `local` everything that is not deliberately exported. Cache library functions you call in
  hot paths at file scope.
- Functions on a namespace table use dot syntax: `function Model.Plan(target, live)`.
  Colon syntax is for things with a `self` worth having: a mixin, or a widget's own
  method. Pure helpers that nothing outside the file calls are `local function`.
- Name booleans as questions (`isScanning`, `hasData`), tables as plural nouns, constants
  in `UPPER_SNAKE` at the top of the file with a comment saying what unit they are in.
- Prefer early returns over nested `if` blocks.
- Comments say why, not what. A comment above a function states what it takes, what it
  returns, and any side effects the caller must know about.
- No trailing whitespace. Files end with a newline. Unix line endings.
- A quoted string stays on one line. Lua has no multi-line `"..."`, the client
  refuses to load a file containing one, and `luaparser` does not notice -- so
  `scripts/lint.py` checks for it separately. Break long text with `..` instead.

## Client API rules

- **No client API is used until it is confirmed on this client**, by the in-game probe
  (`/keel probe`, `/tuner probe`) or by the exported interface source. What is confirmed
  is written to `Docs/client-reference.md`.
- **Modern first.** Where the client has a current mechanism and a legacy one, use the
  current one: the Addon Compartment, `MenuUtil`, the Settings panel, the `C_` namespaces.
- Ask the client through `Env.Try` when a call may not be supported, and through
  `LibKeelRestrict-1.0` for anything combat, an encounter or a chat lock can switch off or
  hide. A value the client hides is nil, and nil means "not known", never "no".
- Target one interface version and put it in the `.toc`. Check the number against an
  installed, up-to-date addon on that client rather than guessing.
- Guard every optional dependency: check the global exists and the function is a function
  before calling, and wrap unsupported internal APIs in `pcall`.
- Anything that waits on the client is a state machine with a timeout on every wait. Never
  loop on a condition that the client might never satisfy. Every stuck state must have a
  way out that does not need `/reload`.
- **Idle means zero work.** No `OnUpdate` when idle and no polling. Use `C_Timer.After`
  for delays. Wrap every event handler and slash command with `Env.Wrap` where it is
  registered, so `/keel profile` shows what it costs.
- Frame pools over frame churn: reuse widgets on refresh, hide extras.

## Saved variables

- One account-wide table and, if needed, one per-character table, declared in the `.toc`
  and handed to `Store.Register` at file scope in `Core.lua` as `account` and `character`.
  The addon reads them as `ns.db` and `ns.cdb` from `onReady` onward.
- Every field has a default in the `defaults` table given to `Store.Register`. Defaults are
  filled in on every load and keep what is there, a stored `false` included, so a new
  field needs no migration of its own.
- A change that has to read the old shape is a step in `migrations`, keyed by the schema it
  upgrades from, and `schema` goes up with it. Steps run before the defaults and never
  delete user data.
- `onReady` is handed `info`. When `info.lost` is true the account file came back empty
  although this character has run the addon before: say so in red at login and tell the
  player to restart before logging out, because a logout writes the empty table over the
  file. `scripts/lint.py` fails an addon that declares saved variables and does not boot
  them through the store.
- Editing a `.toc` needs a client restart. `/reload` does not re-read it, and a client that
  has been running across `.toc` edits is exactly what produces `info.lost`. Restart the
  client before reading a line of addon code.
- Store timestamps as `time()` integers and day buckets as `floor(time() / 86400)`. Store a
  frame's place as fractions of the screen (`W.GetPlace`), not pixels.

## User-facing text

- Chat output goes through the addon's `out` from `Console.New`, which prefixes the addon
  name: `out.Print`, `out.Printf`, and `out.Debug` for maintainer lines. The libraries
  never print; an addon decides what to say, in its own voice.
- Every slash command is a row in the `HELP` table in `Core.lua`, which is what
  `/<cmd> help` prints, and a function in `COMMANDS`; both go to `Console.Slash`. The bare
  command is the `""` entry, and a word with no entry prints the help.
- Anything that can silently do nothing (a setting the client refused, a value it hid)
  prints a reason.
- Colours in a window come from the theme by role, never as literal numbers: `good`,
  `warn` and `bad` for status text, `accent`, `textDim` and the rest as listed in
  `Docs/Keel.md`. Use one meaning per role across the whole addon. `Theme.Hex(color)`
  turns a role's colour into a code for inline text.
- Every label, tooltip and chat line is checked on all the themes that ship: a colour that
  reads on the dark default can vanish on Paper.

## Window layout

- Build windows from `LibKeelWidgets-1.0`: panel, label, button, check box, edit box,
  slider, choice, tabs, list, scroll, menu, confirm. Do not hand-roll a control or paint
  one with literal colour values; every widget repaints when the theme changes.
- Every list has a column header row, in a frame **above** the scroll, never inside the
  scrolled content, so headers stay put while rows scroll. `W.List` does this by
  construction. A compact always-on panel may use section rows instead, as long as its
  rows are still fixed height and single line.
- List rows are fixed height and single line. Cells truncate; the full text goes in a hover
  tooltip or a detail panel. Never let a row's text decide the row's height, and never
  measure wrapped text to lay out a list.
- Toolbars (add, search, sort, filters, bulk actions) sit in a row above the headers.
  Nothing is anchored over the scroll area. A footer strip below a list is allowed only for
  things that belong at the end of it (a totals line, a hint) and only when the list
  reserves its full height, so the two can never share a pixel.
- A page never overflows its frame. Add up the vertical offsets when you edit a form; if the
  total exceeds the page height, put the form in a `W.Scroll`.
- A window opens away from the middle of the screen, keeps its place per character, closes
  on Escape, and gives the keyboard back when combat starts.
- Timestamps in lists show relative age (12s, 5m, 3h, 2d). The exact time goes in the tooltip.
- A button that toggles something shows the current state in its label or kind, and the
  window refreshes after the click.
- A toggle that changes which rows a list shows is saved state, not session state. Kept on a
  Lua table it resets on reload, and a list that comes back empty reads as lost data rather
  than as a filter. Say how many rows are being held back, too.

## Versioning and release

- Semantic-ish: bump patch for fixes, minor for features, major for saved-variable
  schema changes that are not backward compatible.
- The version appears in three places and must match: `## Version:` in the `.toc`, the
  `local VERSION` in `Core.lua`, and the addon's row in `AddonProjects/forever/README.md`.
  `scripts/lint.py` checks all three against each other.
- A Keel library's MINOR goes up whenever its API changes, in the library source and in the
  Contents table of `Docs/Keel.md` together; `lint.py` fails when the two disagree.
- Commit messages: imperative subject under 72 characters, a body that says what changed
  for the player and anything a maintainer must know (migrations, new commands).
- `Docs/releasing.md` has the release steps.

## Review checklist

- `python scripts/lint.py` is clean.
- The addon's cases pass headless (`scripts/run-tests.ps1 -Flavor forever -Addon <Addon>`)
  and in game (`/<cmd> test`).
- Loads without errors on the target client with `Load out of date AddOns` off.
- Every new command is in `help`.
- Every new wait has a timeout and a visible failure message.
- No new globals.
- Docs updated: the addon's guide in `Docs/` and this file if a convention changed.
