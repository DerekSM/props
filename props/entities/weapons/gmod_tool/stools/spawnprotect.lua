TOOL.Category           = "Props"
TOOL.Name               = "Protect Spawnpoints"
TOOL.Command            = nil
TOOL.ConfigName         = ""

function TOOL:RightClick(trace)
end

function TOOL:LeftClick(trace)
end

if CLIENT then
    language.Add("Tool.spawnprotect.name", "Spawn Protect")
    language.Add("Tool.spawnprotect.desc", "Draw a box to protect spawn from noobs")
    language.Add("Tool.spawnprotect.0", "Left click: add a point. Right click: Undo last")
end
