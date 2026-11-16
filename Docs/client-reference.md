# Client reference

Facts about the WoW Forever client that addons here depend on. Verify against an installed,
recently updated addon's `.toc` before relying on a number; Blizzard bumps these with
patches.

## Interface versions

| Flavor | Folder | Interface | Notes |
| --- | --- | --- | --- |
| forever | `_forever_` | 16001 | WoW Forever, in beta as product `wow_classic_beta` (1.60.1). Modern client base; see below |

An addon whose `.toc` interface is lower than the client's is flagged out of date and
will not load unless the player ticks "Load out of date AddOns".

## What is known about forever (16001)

The flavor name to folder, interface and library mapping is `scripts/flavors.psd1`. The
client installed as `_classic_beta_` while in beta and runs as `Wow.exe` from `_forever_`; `.build.info` lists it as
`wow_classic_beta`. Everything below was confirmed on build 1.60.1 (70124) on 2026-09-30,
either by `/keel probe` running in the client (the report is saved to `KeelDB.probe`) or
by reading the exported interface source.

**It is the modern client base.** `WOW_PROJECT_ID` is 1, the same value as
`WOW_PROJECT_MAINLINE` (`WOW_PROJECT_CLASSIC` is 2), so a check for "is this Classic" by
project id says no. Branch on the interface number or on whether an API exists, never on
the project id.

Present: `C_AddOns.GetAddOnMetadata` and `IsAddOnLoaded`, `C_Timer.After` and `NewTicker`,
`C_Item.GetItemInfo`, `C_Container`, `C_AuctionHouse`, `C_TooltipInfo` with
`TooltipDataProcessor`, `C_ChatInfo.SendAddonMessage` and `RegisterAddonMessagePrefix`,
`MenuUtil.CreateContextMenu`, `Settings.RegisterCanvasLayoutCategory`, `StaticPopup_Show`
with `StaticPopupDialogs`, `EditModeManagerFrame`, `AddonCompartmentFrame`,
`CreateFramePool`, `Mixin`, `hooksecurefunc`, `issecretvalue`, `debugprofilestop`,
`C_AddOnProfiler.GetAddOnMetric`, `UpdateAddOnMemoryUsage` and `GetAddOnMemoryUsage`,
`UpdateAddOnCPUUsage`, `GetAddOnCPUUsage` and `GetFunctionCPUUsage`, `GetCVar` and
`C_CVar.GetCVar`, `GetServerTime`, `GetPhysicalScreenSize`, `UISpecialFrames`,
`UIDropDownMenu_Initialize`, and the font objects `GameFontNormal`, `GameFontNormalSmall`,
`GameFontHighlight`, `GameFontHighlightSmall`, `GameFontDisableSmall`.

Absent: the globals `GetAddOnMetadata` and `GetItemInfo`, `EasyMenu`,
`InterfaceOptions_AddCategory`, and the legacy auction call `QueryAuctionItems`. Anything
written for an older client that uses these does not run here.

Frame templates that create without error: `BackdropTemplate`, `UIPanelButtonTemplate`,
`UICheckButtonTemplate`, `InputBoxTemplate`, `UIPanelScrollFrameTemplate`,
`BasicFrameTemplateWithInset`, `UIPanelCloseButton`. The modern scroll pieces
(`WowScrollBoxList`, `MinimalScrollBar`) are in the source too.

Methods: `Texture:SetColorTexture` exists, and a frame made without `BackdropTemplate` has
no `SetBackdrop`. Draw fills and edges with colour textures and a widget needs no template
at all. The moving, clamping, edit-box and check-button methods the widgets use are all
present, as are the script handlers `OnDragStart`, `OnDragStop`, `OnMouseDown`, `OnEnter`,
`OnEnterPressed`, `OnEscapePressed`, `OnEditFocusLost`, `OnTextChanged` and `OnClick`.

**Character names are two-part.** `UnitName("player")` and `UnitFullName("player")` both
return two values that are the character's two names (a first and a second name), not a
name and a realm. `GetRealmName()` is "Classic Beta PvE 2" and `GetNormalizedRealmName()` is
"ClassicBetaPvE2". Never build a "Name-Realm" key by hand; use the per-character saved
table, or `UnitGUID` when a key is needed.

Load order is `ADDON_LOADED`, `PLAYER_LOGIN`, `PLAYER_ENTERING_WORLD`, and both the
account and the per-character saved tables are in hand at `ADDON_LOADED`. Both are written
on `/reload`.

`GetBuildInfo()` returns six values here: version, build, date, interface, then two empty
strings. `UIParent` on a 3840 by 2160 screen was 1923 by 1082 at an effective scale of
0.71, so positions are stored as fractions of `UIParent`, not as pixels.

The interface source is exported at `_classic_beta_\BlizzardInterfaceCode` (launch with
`-console`, then `ExportInterfaceFiles code` at the login screen; it cannot be run in
game). Grep it before using an API the probe did not cover, and re-export after a patch.

### Rendering and console variables on forever

Found by `/tuner probe` and `/tuner capture` in RenderTuner (1.60.1, D3D12, RTX 4090).

**There is no DLSS, DLAA, XeSS, or FSR 2 and later.** `WowB.exe` holds none of their
strings and no upscaler library ships with the client. The only upscaler is FSR 1.0,
`ResampleQuality` 3, used when `RenderScale` is under 1. Low latency is NVIDIA Reflex and
Intel XeLL (`LowLatencyMode`), which do not add frames.

**Listing console variables.** `ConsoleGetAllCommands()` is a global (there is no
`C_Console`) and returns every command as `{ command, help, category, commandType }`. This
client has 1,807 console variables; 186 are in category 1 (Graphics), and several that
matter for graphics are in category 5 (Default) with no help text: `RenderScale`,
`ffxAntiAliasingMode`, `MSAAQuality`, `vsync`, every `graphics*` quality level, `farclip`,
the shadow variables. The category alone does not find "everything graphics".
`C_CVar.GetCVarInfo(name)` returns value, default, two server-storage flags, then locked,
secure and read-only; an addon may set a variable only when the last three are false. Of
the Graphics category only `colorblindSimulator`, `colorblindWeaknessFactor` and `daltonize`
are secure.

**Values come back as text** and not always as one number: `MSAAQuality` reads `"3"` or
`"3,0"` (level, coverage), `RenderScale` reads `"0.670000"`. Compare as numbers.
`GetMinRenderScale()` is 0.33333334 and `GetMaxRenderScale()` is 2; a value written back
with fewer digits than the floor is under it, so round the floor up.
`MultiSampleAntiAliasingSupported()` returns triples of quality text, samples and coverage:
`"1,0", 2, 2, "2,0", 4, 4, "3,0", 8, 8`. `AntiAliasingSupported()` returns three flags for
FXAA, CMAA and CMAA2.

**An addon can capture the world into a texture.** `C_ReportSystem.TakeReportScreenshot()`
is not restricted. `REPORT_SCREENSHOT_READY` fires about 0.03 seconds later, and
`C_ReportSystem.SetScreenshotPreviewTexture(texture)` then puts the capture on any
texture, where `GetTexture()` reads `DrawInternalScreenshotCapture_0`. The capture is the
world only, with no interface in it, covers the whole screen, and lines up with the live
picture when the texture fills `UIParent`; shown on half the screen with
`SetTexCoord(0, 0.5, 0, 1)` it was as sharp as the live half on a 3840 by 2160 screen. No
sound plays and no Blizzard window opens. The photo-sharing twin of this
(`C_PhotoSharing.TakePhoto`) does nothing here: `C_PhotoSharing.IsEnabled()` is false and
`PhotoSharingFrame` does not exist.

**What a machine supports.** `IsGraphicsCVarValueSupported(cvar, value)` is the check the
game's graphics page greys its options out with. It returns 0 for a value that is fine and
otherwise an index into a list of `VRN_*` global strings (`VRN_ILLEGAL`, `VRN_UNSUPPORTED`,
`VRN_NEEDS_RT`, and so on; the order is at the top of
`Blizzard_SettingsDefinitions_Shared/Graphics.lua`). Blizzard asks it only about
`LowLatencyMode`, `textureFilteringMode`, `shadowrt`, `vrsValar` and `msaaAlphaTest`; what
it answers for any other variable is not known, so do not ask. Ray traced shadows cannot
be changed on this client at present. `IsGraphicsSettingValueSupported(cvar, value, raid)`
is the twin for the `graphics*` quality levels.

**Quality levels.** Setting a `graphics*` level (`graphicsShadowQuality`) does move the raw
variables beneath it. Setting the overall `graphicsQuality` does not move the other
levels: the graphics page does that in Lua, asking
`GetGraphicsCVarValueForQualityLevel(cvar, level, raid)` for each one.

**What each level moves**, read with `/tuner probe ranges` on build 70938 by walking the raid
copy of each level (a stored set: nothing on screen changes outside a raid) and watching the
`RAID*` variables. Values are for the level's 0 upward.

| Level (top) | Moves |
|---|---|
| ViewDistance (9) | `farclip` and `horizonClip` 3000 to 10000, `horizonStart` 400 to 4000, `terrainLodDist` 200 to 650, `TerrainLodDiv` 384, 512, 768, `wmoLodDist` 250 to 400, `entityLodDist` 5 to 10, `entityShadowFadeScale` 10 to 50 |
| EnvironmentDetail (9) | `doodadLodScale` 50 to 150, `lodObjectCullSize` 35 down to 14, `lodObjectFadeScale` 50 to 150, `lodObjectMinSize` 0, then 30 and 20 at the top two |
| GroundClutter (9) | `groundEffectDensity` 16, 32, 48, `groundEffectDist` 40 to 320 |
| ShadowQuality (5) | `shadowMode` 2 to 4, `shadowNumCascades` 3 or 4, `shadowSoft`, `shadowTextureSize` 512, 768, 1024, 1536, 2048 |
| LiquidDetail (3) | `waterDetail` 0 to 3, `reflectionMode` 0, 2, 2, 3, `rippleDetail` 0 to 2 |
| DepthEffects (3) | `DepthBasedOpacity`, `refraction` 0 to 2, `sunShafts` 0 to 2 |
| ComputeEffects (4) | `volumeFogLevel` 0 to 4 |
| ParticleDensity (4) | `particleDensity` 10 to 100, `particleMTDensity` 20 to 100, `weatherDensity` 0 to 3 |
| LightMode (3) | `giQuality` 1 to 4, and `RenderFormat`: 1 at the bottom level, 2 above it |
| TextureResolution (2) | `worldBaseMip` 2 to 0, `terrainMipLevel` and `componentTextureLevel` 1 to 0 |
| SpellDensity (2) | `spellClutter` 1, 2, 4 |
| SSAO (4), OutlineMode (2), PBRLiquidDetail (2), ProjectedTextures (1) | the one variable of the same name |

`graphicsLightMode` takes 3, one more than the three options the exported graphics page
lists, and the client's own answer for quality level 10 is 3. `graphicsParticleDensity`
stops at 4. A level handed a number past its top keeps its top.

**A variable the client checks keeps its last good value when handed a bad one.**
`C_CVar.SetCVar` does not raise and does not return false; reading the variable back is the
only way to tell. Found this way: `groundEffectDensity` takes 16 to 256 and
`groundEffectDist` 40 to 400 (both well past what the levels set), `maxFPSLoading` 10 to
60, `refraction` 0 to 2, `vrsWorldGeo` and `vrsParticles` take `1x1`, `1x2`, `2x1`, `2x2`,
`2x4`, `4x2`, `4x4`, and `screenshotFormat` takes `jpeg`, `jpg`, `png`, `tga`. Many
variables are not checked at all and take any number, -1 included: `giQuality`,
`SkyCloudLOD`, `bodyQuota`, `entityLodOffset`, `lodObjectSizeScale`, `wmoLodDistScale`,
`disableHorizonStart`. For those the client gives no range.

**The count moves between builds.** 1,807 variables with 186 in Graphics on the first
reading; 1,801 with 185 on build 70938 (Nov 12 2026). `/tuner probe` saves the whole list to
`RenderTunerDB.probe`; keep a copy before a patch to see what changed.

**`DynamicRenderScale` has crashed this client.** Its own help text calls it a beta feature.

`MinimalSliderTemplate`, `MinimalSliderWithSteppersTemplate` and the `OffScreenFrame` frame
type can all be created. `RestartGx` and `UpdateWindow` are globals.

## Client folders

Saved variables: `<flavor>\WTF\Account\<ACCOUNT>\SavedVariables\<Addon>.lua`, written on
logout and `/reload` only; the previous write survives as `.lua.bak` until the next one.
Lua errors: an error catcher in game or `<flavor>\Errors\`.

`.toc` files are read once, at client start. Editing a `.toc` needs a client restart.
`/reload` does not re-read it, and a client that has been running across `.toc` edits can
stop restoring one addon's account-wide saved variables while still restoring the
per-character ones. LibKeelStore reports that as `info.lost`. The file on disk is written
correctly each time and the client's own logs say nothing; a restart fixes it outright.
Restart the client before reading a line of addon code. `AddOns.txt` is not
evidence either way: it is rewritten only from the AddOns screen and does not list addons
left at their default enabled state.

## The AddOns list

The list has two levels: a heading, and addons under it.

- **`## Category:`** is the heading. It is free text, and a string nobody else uses gets a
  heading of its own. Confirmed here: RenderTuner is `## Category: Graphics`, Stickies
  `Notes` and Keel `Libraries`, and each sits under that heading. An addon names its heading
  by what it is for, not by who made it.
- **Do not put a texture in `## Title` if the addon also has an `## IconTexture`.** Both
  draw, so the row gets two icons side by side.

The rest was learned on an earlier client and has not been re-checked on 16001; nothing
here uses it:

- **`## Group:`** nests an addon, indented, under the row of the addon that heads its
  cluster. The value must be an addon folder that exists, and the head names itself. A
  free-text value is not used as a label: the client drops the addon out of grouping
  altogether. A cluster has no name of its own; the heading you read is the head addon's
  `## Title`.
- A shared folder-name prefix (`Name` and `Name_Something`) nests the same way with no
  `## Group:` line at all.
- A `## Title` can carry an inline texture with `|T...|t`; the escape takes the path
  without a file extension while `## IconTexture` takes it with one.
