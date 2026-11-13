# RenderTuner

The one place to tune WoW Forever's graphics: upscaling and quality presets, a live control
for about 160 console variables, search, and a way back to what you had.

**Version 0.6.0 has the floating panel and the commands**, an Extreme quality preset with
the experimental extras, and a panel that can get out of the way of the world it tunes. It
says which quality level the game recommends for your machine, warns before Extreme when your
frame rate is already low, and measures your frame rate and takes the step it suggests
(**Auto-set**, with **Undo**). The page in the game's Options window and the side-by-side
comparison come next.

**New in 0.5.0:** the 67% upscaling preset is **Crisp** (it was Quality, which is also the
name of the row below it; `/tuner preset quality` still finds it). **Save** is **Keep**,
because the game already remembers every change and the button only moves where Revert goes
back to. Auto-set counts down while it measures and says what it did in the title bar;
**Undo** puts back what Auto-set or Extreme changed; the recommended quality level keeps a
bar under its button; the frame rate window closes on Escape.

**New in 0.5.1:** the AddOns list shows RenderTuner on its own under a **Graphics** heading,
not under Impulse Control and ICKit.

**New in 0.6.0:** twenty-four more settings, after the client's whole list of console
variables was read again. Among them: ground clutter density and distance, which go well
past the top of the game's own slider; the screenshot format; a frame rate limit for loading
screens; refraction; shading rates for the world and for particles; and character texture
compression, highlights and glow. Extreme now takes ground clutter to the client's ceiling.
Three ranges were wrong and are put right: Lighting quality has a fourth level, Particle
density has five, not six, and Light distance stops at 2048, the most the client keeps.

## What the client can and cannot do

The Forever client (1.60.1) has **no DLSS, DLAA, XeSS, or FSR 2 and later**. The client
binary holds none of them and no NVIDIA upscaler library ships with the game. The "DLSS 5"
videos of Forever use outside tools that inject into the game; an addon cannot do that, and
this one does not try.

What the client does have is a render scale with an FSR 1.0 upscale and a sharpening pass,
image and multisample anti-aliasing, low latency modes, HDR and colour correction, all
driven by console variables an addon may set. RenderTuner sets those and nothing else.

FSR 1.0 is a spatial upscaler: it sharpens a lower-resolution frame and has no memory of
earlier frames. An upscaling preset built on it raises the frame rate the way a DLSS preset
does, and it does not look the same.

## Install

Extract into `_forever_\Interface\AddOns` so you get `AddOns\RenderTuner\RenderTuner.toc`.
RenderTuner needs **ICKit**, which goes beside it (`AddOns\ICKit`). Restart the client after
installing; a `/reload` does not pick up a new addon.

## Some settings can crash the game

Settings marked **experimental** can crash the game or leave it unable to draw the world.
They depend on your graphics card and its driver, and the client itself calls some of them
beta features. The ones marked so far:

| Setting | Why |
| --- | --- |
| Dynamic render scale | The client's own help text calls it a beta feature, and it has crashed the 1.60.1 client |
| HDR output | Depends on the monitor and the render format, and restarts the graphics engine |
| Render format | Changes the precision the whole picture is drawn at, and restarts the graphics engine |
| Ray traced shadows | Needs a graphics card and driver that support ray tracing |
| Variable rate shading, VRS always on | Needs hardware support, and changes how the picture is shaded |
| World shading rate, Particle shading rate | The same hardware feature, applied to one kind of thing |

The mark shows beside the setting's name in the panel, in its tooltip and in `/tuner list`.

In the panel, turning an experimental setting on asks first. Turning one off never asks.

The first time you open the panel in a session, a warning says this and waits for
**I understand**. Tick **Do not show this again** and it stays away for good.

**Keep a set that works before trying one**, so Revert has somewhere to return to. If the
game will not start afterwards, delete `WTF\Config.wtf` in the game folder
(`_forever_\WTF\Config.wtf`): the client starts with default settings and writes a new
one. That file holds machine-wide settings only, such as graphics and sound, not your
characters, keybinds or addons' data.

## The panel

`/tuner` opens it. So does a left-click on RenderTuner in the addon list beside the
minimap, and a key you bind under Options, Keybindings. A right-click in the addon list
offers the upscaling presets without opening anything. Drag the panel by its title bar;
Escape closes it. Its place is kept per character, and it starts toward the left edge, so
the middle of the screen stays clear.

**The title bar** shows the frame rate, measured twice a second while the panel is open, and
where things stand: "Upscaling 67% Crisp, 2 changed". For a few seconds after Auto-set it
says what that did instead: "Auto-set: Upscaling Balanced 58%, was Native".

**Getting out of the way.** The panel sits over the world you are tuning, so it can step aside:

- **Peek**, in the title bar, makes the panel nearly clear for as long as you hold the
  button. **Hold to see the world behind the panel** is also a key binding, under Options,
  Keybindings, AddOns: hold the key, look, let go.
- **Compact** folds the panel to the title bar and the two rows of presets. **Expand**
  brings it back. Which one you left it in is kept per character.
- **While a slider is held** the panel goes half clear, so you see what the thumb is doing.

**Two rows of presets** run across the top, from least to most, left to right. The one in
use in each is highlighted.

- **Upscaling** sets the render scale and the resample filter and nothing else. Each button
  shows the share of the screen's pixels it draws. "Performance" and "Balanced" here are
  the names upscalers use for render scales; they do not touch the quality levels.
- **Quality** sets the game's overall quality level, and the levels beneath it, and leaves
  upscaling alone. **Extreme**, at the right in orange, is Ultra and then everything the
  quality levels do not reach, turned all the way up (see below), after asking. Choosing a
  lower level puts those settings back as they were before Extreme.

**The game's recommendation.** The level the client recommends for this machine (its own
default for the overall level) keeps a bar under its button, whichever level is in use: dark
on the gold of the one in use, green otherwise. Until you pick a quality preset, the line
under the rows also says which button it is, or which is the closest; the button's tooltip
says so from then on. If your frame rate is under 40 when you click Extreme, the question and
the button's tooltip say so first.

Clicking a preset brings the group it changes into view, so you see what it did. The two
rows are independent: Potato upscaling with Ultra quality is a combination you can make.

**Keep** makes the settings as they are now the set Revert returns to, and counts what is
waiting ("Keep (2)"). The game already remembers every change you make; Keep only moves the
point Revert goes back to. **Revert** puts everything back to the kept set. **More...** has
the client's defaults, the way back to before RenderTuner, a frame rate check, and a restart
of the graphics engine.

**Auto-set**, at the right, measures your frame rate for about six seconds (the button counts
the seconds down) and takes the step it suggests: see the frame rate check below. **Undo**
appears beside it afterwards, and after Extreme: one step that puts back every setting the
change moved. It goes away when you change anything else, so it never undoes more than it
offered to.

**The search box** finds settings by name, by console variable, by what their help says or
by group, across every group at once: type `shadow` or `fps`. Escape clears it.

**Down the left** are the groups, in three clusters: Picture, Detail and Advanced. Advanced
is folded away until you open it (the line saying `Advanced +`), and says how many of its
settings changed while it is shut. **Changed**, at the top, lists everything that differs
from the kept set, whatever group it is in. A group with changes shows a count.

**The rows on the right** are the settings in view, and they scroll with the mouse wheel.
The line under them says what the setting under the pointer does.

- **Click a slider's number** to type a value instead of dragging: `67` for 67%, a level
  from 1, nits or frames as they read. Enter sets it; Escape or clicking away drops it.

- A change takes effect as you make it, with the world in view behind the panel.
- A setting that differs from the kept set is in the accent colour and gains a **Revert**
  at the end of its row, which puts that one setting back. **Revert these**, in the
  heading, puts back everything in view.
- **Hover a setting's name** for what it does, its console variable, its kept value, the
  client's default and its range. **Click the name** to choose between the kept value
  and the client's default.
- **A greyed-out setting** is one this client will not change at the moment, such as ray
  traced shadows. Its tooltip gives the client's reason. In a dropdown, single choices
  the client refuses are greyed the same way.
- **Overall quality**, in Quality levels and in Raid profile, moves the levels beneath
  it, as the same slider does on the game's own graphics page.

**Restart graphics** appears when a change needs the graphics engine restarted before it
shows (multisampling is one). RenderTuner asks to restart it when you make such a change; say
not now and the button stays until you do. A change that needs the whole game restarted, such
as one of Extreme's, cannot be done by an addon, and it says so.

The render scale slider applies when you let go of it rather than on every step, because
each change rebuilds what the client draws into. Every other slider is live.

## Presets

**Upscaling:**

| Preset | Render scale | Resample filter |
| --- | --- | --- |
| `potato` | 33% (the client's floor) | FSR 1.0 |
| `performance` | 50% | FSR 1.0 |
| `balanced` | 58% | FSR 1.0 |
| `crisp` | 67% | FSR 1.0 |
| `native` | 100% | left as it is |

`/tuner preset crisp` uses one; the start of a name is enough (`/tuner preset perf`), and
`quality`, the 67% preset's name before 0.5.0, still works.
`/tuner off` goes to native and `/tuner on` returns to the last upscaling preset you used.
A preset does not touch the sharpening strength, so it stays where you set it.

**Quality:**

| Preset | Overall quality, of 10 |
| --- | --- |
| `low` | 1 |
| `fair` | 3 |
| `good` | 5 |
| `high` | 7 |
| `ultra` | 10 |
| `extreme` | 10, and about fifty settings beyond the levels at the top of their ranges (experimental) |

`/tuner quality high` uses one. Each sets the overall level and asks the client what every
level beneath it should be at that level, which is what the slider on the game's own
graphics page does.

**What Extreme means.** The game's ten levels move only the dozen or so variables its
graphics page lists. Everything else is left where the client's first run put it, well short
of the ceiling: view distance 7000 of 10000, three shadow cascades of four, a 16-bit float
render format when a 32-bit one exists, and no multisampling.
Extreme is Ultra, then each of these at the top of its own range:

- **The picture:** 32-bit float render format, HDR output, 8x multisampling with CMAA2 at
  Ultra, 16x anisotropic filtering, full-resolution textures.
- **Shadows and light:** the best shadow technique, four cascades, shadows on every creature
  out to the limit, ray traced shadows, Ultra ambient occlusion, the finest volumetric fog,
  and the light range at the client's limit of 2048.
- **Distance and detail:** draw distance and horizon at 10000, terrain and building detail
  at 650, props at twice the usual range, creature detail at 30, nothing dropped for being
  small, grass out to 500, and ground clutter at a density of 256 out to 400 where the top
  level of the game's own slider stops at 48 and 320.
- **Water, weather, particles:** every water, ripple and reflection setting at its best,
  reflections at full resolution, full particle density, crowds never thinned.
- **Nothing shaded down:** variable rate shading off, the world and particle shading rates
  at 1x1, no animation frames skipped at a distance, and cloth and foliage moving on every
  character.

It leaves out what is taste rather than quality (bloom, field of view, the glow and other
full-screen effects, the ambient-occlusion tuning, frame rate limits), the render scale
(the upscaling row owns it), and the raid profile.

It asks first, because HDR output, the 32-bit format and ray traced shadows can crash the
game. A setting the client will not take on your machine, such as ray traced shadows without
ray tracing, is left alone and named. Before it changes anything it notes what each setting
was; choosing a lower level puts them back as they were, exactly. If you tune one of them
by hand after Extreme, the button no longer lights, and a lower level leaves them to you.

## The frame rate check

RenderTuner measures your frame rate for about six seconds (twelve readings, the middle one
counts) and opens a window with the number and one suggestion, and a button that does it.

- **Under 40 fps:** one step down. Upscaling first (Native to Crisp 67%, and so on); once
  upscaling is at its lowest, one quality level.
- **100 fps or more:** one step up. Toward native first, then one quality level. Never up
  to Extreme, which is asked for.
- **In between:** the window says it is comfortable and offers nothing.
- **Vertical sync on:** the game is held to your screen's refresh rate, so a frame rate that is
  not low says nothing about room. The window says so and suggests turning it off to check.

**Auto-set** (the button, or `/tuner auto`) takes that step without the window: the button
counts the seconds down, the chat and the title bar say what it did ("Auto-set: Quality High,
was Good"), and **Undo** puts it back. When there is nothing to take, the window says so.

The automatic check does not believe a reading at the background frame rate limit (the game
was behind another window); it looks again twice, half a minute apart, then leaves it to the
next login. `/tuner check` is taken to be run with the game in front, and always stands.

It runs by itself about ten seconds after login the first time RenderTuner is used, and
again whenever the settings arrive at the client's defaults (for example after **More...**,
Client defaults). Not on every login there, and never in combat. Tick **Do not check at
login** in the window to stop the automatic check; `/tuner check` and **More..., Check my
frame rate** always run it. The reading depends on where you stand, so stay in the world,
somewhere typical.

## Kept, trial and original

The settings that are live in the game are the only copy that matters. RenderTuner keeps
two sets to go back to:

- **Kept** is what `/tuner keep` last recorded (`/tuner save` still does the same).
  `/tuner revert` returns to it.
- **Original** is what was live the first time RenderTuner ran. `/tuner restore` returns
  to it, whatever you have kept since.

Anything you change is a trial until you keep it. Trial changes survive a `/reload` and a
logout, because the client stores console variables itself; the login line tells you how
many settings differ from the kept set.

## Commands

`/tuner` or `/rendertuner`.

| Command | What it does |
| --- | --- |
| `/tuner` | Opens or closes the panel |
| `/tuner status` | The render scale, its preset, and how many settings differ from kept |
| `/tuner preset [name]` | Lists the presets, or uses one |
| `/tuner on`, `/tuner off` | Upscale with the last preset used, or go back to native |
| `/tuner quality [name]` | Lists the overall quality presets, or uses one |
| `/tuner list` | The groups, with how many settings each has and how many have changed |
| `/tuner list <group>` | Every setting in a group with its value, and the kept value where it differs |
| `/tuner list changed` | Only the settings that differ from kept |
| `/tuner set <variable> <value>` | Sets one console variable from the catalogue |
| `/tuner keep` | Records the live settings as the kept set (`/tuner save` does the same) |
| `/tuner revert` | Goes back to the kept set |
| `/tuner undo` | Puts back what the last Auto-set or Extreme changed |
| `/tuner defaults` | Sets everything to the client's defaults for this machine |
| `/tuner restore` | Goes back to how things were before RenderTuner first ran |
| `/tuner restart` | Restarts the graphics engine, for the few changes that need it |
| `/tuner check` | Measures the frame rate for six seconds and opens a window with a suggestion |
| `/tuner auto` | The same measurement, taking the step it suggests (the panel's Auto-set) |
| `/tuner test` | Runs the built-in checks |

`/tuner set` takes the value as `/tuner list` shows it: a number for a slider or a choice
(`/tuner set ffxAntiAliasingMode 4`), `on` or `off` for a toggle. A slider value is snapped
to its step and kept inside its range; a choice that is not offered is refused, with the
list of what is. A quality level is counted from 1, as the game shows it.

Two keys can be bound under Options, Keybindings, AddOns: one opens and closes the panel,
the other is Peek, held to see the world behind it. A new key binding needs a full client
restart to appear.

## The settings

About 140 console variables in sixteen groups. A variable this client does not have, or
will not let an addon set, is left out when the addon loads.

| Group | `/tuner list` name | What is in it |
| --- | --- | --- |
| Upscaling | `upscale` | Render scale, resample filter, sharpening, dynamic render scale |
| Anti-aliasing | `aa` | FXAA, CMAA, CMAA2 with its quality and precision, multisampling |
| Latency and frame rate | `frame` | Reflex and XeLL, vertical sync, triple buffering, frame rate limits and target, the loading screen limit |
| Colour | `colour` | Gamma, brightness, contrast |
| HDR | `hdr` | HDR output, brightness and peak overrides, HDR factor, render format |
| Quality levels | `quality` | The overall level and the fifteen levels beneath it, from the game's own graphics page |
| Shadows | `shadow` | Shadow technique, resolution, cascades and range, ray traced shadows |
| Lighting and fog | `light` | Ambient occlusion, sun shafts, volumetric fog, bloom, specular, light distance, lighting detail, lighting on transparent surfaces |
| Ambient occlusion tuning | `ssao` | The contact-shadow shader's own controls: radius, strength, contrast, blur, fade, and how it blends its two sources of surface direction |
| Textures | `texture` | Filtering, resolution of world, terrain and character textures, and character texture compression, highlights and glow |
| View distance and detail | `world` | Far clip, fog, how far terrain, buildings, objects and creatures keep their detail, ground clutter density and distance, dynamic detail |
| Water and weather | `water` | Water detail and shading, ripples, reflections, refraction, weather density |
| Particles and spells | `particles` | Particle density, spell clutter, projected textures, thinning out crowds, how many dressed characters are drawn |
| Effects and camera | `effects` | Field of view, full-screen effects, outlines, variable rate shading and the two shading rates, physics |
| Raid profile | `raid` | A second set of quality levels the game uses inside raids, and the switch for it |
| Cursor and screenshots | `misc` | Hardware cursor, cursor size, screenshot quality and format |

Left out on purpose: the raw variables beneath the raid levels (the raid levels themselves
are there); variables that take free text, such as the graphics API and the adapter; the
engine's threading, streaming and debugging variables; the window and monitor settings; and
what the game's own Combat and Accessibility pages own, such as camera shake and the
self-highlight. The whole of the client's list was read again for 0.6.0, and the header of
`Catalog.lua` says what stays out and why.

Where the client checks a variable, the range is the client's: it was asked with
`/tuner probe ranges`, which tries values and reads back what the client made of them. A few
variables take any number at all (object size for culling, building detail scale, dressed
characters, lighting detail); their sliders run over a modest span around the client's own
value, and their tooltips say so.

The ranges of the ambient occlusion tuning sliders come from the client's own help text.
Ranges elsewhere that the client does not state, in HDR and in View distance and detail,
are estimates: a value outside a slider's range is shown as it is and left alone until
you move the slider.

When several settings change at once, the quality levels are set first. The client moves
the variables beneath a level when the level changes, so they have to be set after it.

## The comparison view (coming)

The client draws the world once per frame with one set of console variables, so two
settings cannot be shown side by side live. What works instead: switch to the kept
settings for a moment, capture the world into a texture, switch back, and show the left
part of that capture over the live picture, with a divider to drag. The left side is a
still, right while the camera holds still.

The capture was tested in 0.0.1 and works: it is sharp, lines up with the live picture and
holds the world only, without the interface. `/tuner capture report` still shows it.

## Saved data

| Table | Scope | Holds |
| --- | --- | --- |
| `RenderTunerDB` | account | `saved`, `original`, `settings` (the last preset used, whether the warning is skipped), and for now `probe` and `capture` from the client questions |
| `RenderTunerCharDB` | character | `panel`: where the panel sits and the group it last showed |
