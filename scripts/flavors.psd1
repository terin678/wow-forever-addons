# The game flavors this repo builds for, one entry each. Every script reads this file.
#
#   Folder     the client folder under the WoW install, where Interface\AddOns lives
#   Interface  the .toc interface number the flavor's addons target
#   Library    the shared library addon the flavor's addons depend on
#   Published  the addons that ship, in upload order (library first)
#   Template   the addon new-addon.ps1 copies from; empty while the flavor has none
@{
    # WoW Forever. The beta installs as _classic_beta_; when the live client lands under
    # another folder name, this is the one line to change.
    forever = @{
        Folder = "_classic_beta_"; Interface = "16001"; Library = "ICKit"
        Published = @("ICKit", "Stickies", "RenderTuner"); Template = ""
    }
}
