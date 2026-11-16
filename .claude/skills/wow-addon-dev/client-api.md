# Client contracts that have already cost us

Things that are not obvious from the code, symptom first, because the symptom is what you
will have in front of you. Client: WoW Forever, interface 16001. The full record of what
this client has been proven to do is `Docs/client-reference.md`; this file is the short
list of traps.

## Confirmed on this client

**A setting "took" and nothing changed.** `C_CVar.SetCVar` does not raise and does not
return false when the client refuses a value; a checked variable keeps its last good value.
Reading the variable back is the only way to tell.

**A console variable compares unequal to the number just written.** Values come back as
text and not always as one number: `MSAAQuality` reads `"3"` or `"3,0"`, `RenderScale`
reads `"0.670000"`. Compare as numbers.

**"Is this Classic" says no.** `WOW_PROJECT_ID` is 1, the mainline value. Branch on the
interface number or on whether an API exists, never on the project id.

**A "Name-Realm" key is wrong for every character.** `UnitName("player")` returns the
character's two names, not a name and a realm. Use the per-character saved table, or
`UnitGUID` when a key is needed.

**A global that every old addon calls is nil.** `GetAddOnMetadata`, `GetItemInfo`,
`EasyMenu` and `InterfaceOptions_AddCategory` are absent; the `C_` forms, `MenuUtil` and
`Settings` are what exist.

**`SetBackdrop` is nil.** A frame made without `BackdropTemplate` has none. Draw fills and
edges with `Texture:SetColorTexture`, as LibKeelWidgets does, and a widget needs no
template at all.

**Attributes cannot be touched in combat.** `SetAttribute` on a secure button raises
`ADDON_ACTION_BLOCKED` once `InCombatLockdown()` is true. LibKeelSecure holds every change
until combat ends; a pooled secure row must be disabled rather than left pointing at
someone else's action.

**A value read in combat is not what it seems.** The client hides some values in combat, in
an encounter or under a chat lock (`issecretvalue`). Read them through LibKeelRestrict, and
treat a hidden value as "not known", never as "no".

**Data vanished after a `.toc` edit.** `.toc` files are read once, at client start. A
client that has been running across `.toc` edits can hand back an empty account table while
the per-character one loads. The store reports it as `info.lost`. Restart the client.

## Carried over from an earlier client

These were learned on a different client and have not been re-checked on 16001. They are
about how frames work and are likely to hold, but confirm before relying on one.

**A frame draws with no fill, text still visible.** A texture path that does not resolve is
silent: no error, no placeholder. `Interface\Buttons\WHITE8x8` existed;
`Interface\Buildings\White8x8` did not, and `scripts/lint.py` still fails on it.

**A frame reports `GetWidth()` of 0.** A frame anchored on two sides has no size until the
first layout pass. Anything computing geometry at build time needs a fallback width.

**A FontString ignores `SetScript`.** FontStrings are regions, not frames: no scripts, no
mouse. A hover or clickable cell needs an invisible Button on top of it.

**`Button:SetText` does nothing.** A bare Button has no font string until
`SetFontString(fs)` is called.

**A rotated texture comes out unrotated.** `Texture:SetRotation` turns the picture inside a
rectangle that does not move, so a `SetColorTexture` fill looks identical at every angle.
Draw a chart line as steps: a flat run per slot and an upright joining one run to the next.

**A font string with a set width wraps**, and in a fixed-height row draws over the row
below. `SetWordWrap(false)`.

**A channel list has a stride of three.** `GetChannelList()` returns a flat
`id, name, disabled, id, name, disabled, ...`.

## Lua, not the client

**luaparser does not catch an unfinished string.** A raw newline inside `"..."` is a load
error in the client and `luaparser` parses it happily. `check_unfinished_strings` in
`scripts/lint.py` walks the source properly. The parse check is a floor, not a ceiling.

**A table constructor cannot carry a nil.** `{ channel = nil }` is an empty table, so a
test helper that merges an overrides table silently applies no override. Clear the field on
the built table instead: `local s = state(); s.channel = nil`.

**Data that "disappeared" on reload was usually never saved.** A field on a Lua table that
is not inside the saved table is session state, and a filter or toggle kept there looks
exactly like data loss at the next login. If it changes what the player sees, save it.
