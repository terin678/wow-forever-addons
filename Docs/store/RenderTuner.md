# RenderTuner

**One panel for WoW Forever's graphics.** Upscaling and quality presets you can click while you watch the world change, a live control for about 160 graphics settings the game's own options page never shows, and a way back to what you had.

Type `/tuner` to open it.

## What it does

- **Upscaling presets.** Potato 33%, Performance 50%, Balanced 58%, Crisp 67% and Native 100%. Each sets the render scale, and the ones under 100% switch on the FSR 1.0 upscale. One click, no restart.
- **Quality presets.** Low, Fair, Good, High and Ultra are points on the game's own quality slider. A bar under one of them marks the level the game recommends for your machine.
- **Extreme.** Ultra, and then everything the game's slider does not reach, turned all the way up: view distance, shadow cascades, 8x multisampling, a 32-bit render format, and ground clutter at more than five times the density of the game's top setting. It asks first, and a lower level puts everything back as it was.
- **Auto-set.** Measures your frame rate for six seconds and takes one step up or down for you. **Undo** puts it back.
- **About 160 settings, in sixteen groups.** Shadows, lighting and fog, ambient occlusion, textures, view distance, water, particles, anti-aliasing, HDR, frame rate limits, screenshots and more. Each one has a line saying what it does, its range, and the client's default.
- **Search.** Type "shadow" or "fog" and get every setting that matches, whatever group it is in.
- **Always a way back.** Every change applies at once, so you see it. **Keep** marks a set you like, **Revert** returns to it, and a row's own Revert puts back one setting. Under More... are the client's defaults and the settings you had before you ever installed RenderTuner.
- **Stays out of the way.** Compact folds the panel down to the two preset rows. Hold Peek to see the world through it.

## What it cannot do

The Forever client has **no DLSS, DLAA, XeSS or FSR 2**. No addon can add them, and this one does not pretend to. The upscaler is FSR 1.0: it raises your frame rate the way a DLSS preset does, and it does not look the same.

RenderTuner only sets console variables the client allows an addon to set. It does not inject anything into the game.

## Experimental settings

A few settings are marked **experimental** in the panel: dynamic render scale, HDR output, the render format, ray traced shadows and variable rate shading. They depend on your hardware and driver, and some can crash the game. RenderTuner asks before turning one on.

## Good to know

- **Commands:** `/tuner` opens the panel. `/tuner preset crisp`, `/tuner auto`, `/tuner undo`, `/tuner keep` and `/tuner revert` do what the buttons do. `/tuner help` lists the rest.
- **Also opens from** the addon list beside the minimap (right-click it for the upscaling presets) and from a key you bind under Options, Keybindings, AddOns.
- **ICKit is included.** The download has both folders, RenderTuner and ICKit. Keep them side by side in `Interface\AddOns`.
- **In the AddOns list** it sits under a Graphics heading.
- **Some changes need a restart.** Multisampling and HDR need the graphics engine restarted, which RenderTuner offers to do. One of Extreme's settings needs the game restarted, and it says so.

## New in 0.6.0

- Twenty-four more settings, including ground clutter density and distance, the screenshot format (JPEG, PNG or TGA), a frame rate limit for loading screens, and shading rates for the world and for particles.
- Extreme takes ground clutter to the client's ceiling. If you were already on Extreme, click it once more.
- Fixed three ranges: Lighting quality has a fourth level, Particle density has five, and Light distance stops at 2048.

Made by Malexis. Source and full documentation: https://github.com/terin678/wow-forever-addons
