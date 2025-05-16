TOOL.Category           = "Props"
TOOL.Name               = "Protect Spawnpoints"
TOOL.Command            = nil
TOOL.ConfigName         = ""


    -- 1 = {startpos=VectorHere, endpos=VectorHere}
    -- 2 = {startpos=VectorHere, endpos=VectorHere}
AntinoobSpawnProtectionAreas = AntinoobSpawnProtectionAreas or {}

if SERVER then
        -- The prediction on this is awful so we're just gonna manually network it
    util.AddNetworkString("props_NetworkAntinoobSpawnTool")
    util.AddNetworkString("props_NetworkAntinoobProtectionAreas")

    print("This should only be called once (or on reload)")
    hook.Add( "Initialize", "CreateAntinoobspawnprotectionareas", function()
        file.CreateDir("props/spawnprotection")

        if file.Exists( "props/spawnprotection/" .. game.GetMap():lower() .. ".txt", "DATA" ) then
            AntinoobSpawnProtectionAreas = util.JSONToTable(file.Read( "props/spawnprotection/" .. game.GetMap():lower() .. ".txt", "DATA" ))
        end
    end )

    hook.Add( "InitPostEntity", "CreateAntinoobspawnprotectionareas", function()
        for i=1,#AntinoobSpawnProtectionAreas do
            local v = AntinoobSpawnProtectionAreas[i]

            local trigger = ents.Create( "props_spawntrigger")
            trigger:SetPos( v.startpos )
            trigger:SetKeyValue("mins", tostring(v.startpos))
            trigger:SetKeyValue("maxs", tostring(v.endpos))
            trigger:Spawn()
            trigger.SpawnProtectionAreaLinked = i
        end
    end )

end

function TOOL:Deploy()
    if CLIENT then return end

    local pl = self:GetOwner()

    if not PROPKILL.Config or not PROPKILL.Config["spawnprotection"] then
        if SERVER then
            pl:ChatPrint("Antinoob spawn protection is off. This tool won't do anything!")
        end
        return
    end
    if not PROPKILL.Config["spawnprotection"].default then
        if SERVER then
            pl:ChatPrint("Antinoob spawn protection is off. This tool won't do anything!")
        end
        return
    end

    net.Start("props_NetworkAntinoobSpawnTool")
        net.WriteBool( false )
    net.Send( pl )

    net.Start("props_NetworkAntinoobProtectionAreas")
            -- max of 8 spawn protection areas
        net.WriteUInt(#AntinoobSpawnProtectionAreas, 3)
        for i=1,#AntinoobSpawnProtectionAreas do
            local v = AntinoobSpawnProtectionAreas[i]

            net.WriteVector( v.startpos )
            net.WriteVector( v.endpos )
        end
    net.Send( pl )
end

function TOOL:Holster()
    local pl = self:GetOwner()

    pl.SpawnProtectTooling = false
    pl.SpawnProtectPos1 = nil

    if SERVER then
        net.Start("props_NetworkAntinoobSpawnTool")
            net.WriteBool( false )
        net.Send( pl )
    end
end

function TOOL:RightClick(trace)
    if not PROPKILL.Config or not PROPKILL.Config["spawnprotection"] then return false end
    if not PROPKILL.Config["spawnprotection"].default then return false end
    if #AntinoobSpawnProtectionAreas >= 8 then return false end

    if CLIENT then return true end

    local pl = self:GetOwner()
    for i=1,#AntinoobSpawnProtectionAreas do
        local v = AntinoobSpawnProtectionAreas[i]

        if pl:GetEyeTrace().HitPos:WithinAABox( v.startpos, v.endpos ) then
            props_RemoveAntinoobSpawnProtectionEntry( i, pl )
        end
    end

    pl.SpawnProtectTooling = false

    net.Start("props_NetworkAntinoobSpawnTool")
        net.WriteBool( false )
        net.WriteVector( trace.HitPos )
    net.Send( pl )
    return true
end

function TOOL:LeftClick(trace)
    if not PROPKILL.Config or not PROPKILL.Config["spawnprotection"] then return false end
    if not PROPKILL.Config["spawnprotection"].default then return false end
    if #AntinoobSpawnProtectionAreas >= 8 then
        if SERVER then
            self:GetOwner():ChatPrint("You've reached the max spawnprotection areas for this map.")
        end
        return false
    end

    if CLIENT then return true end

    local pl = self:GetOwner()

    if pl.SpawnProtectTooling then
        pl.SpawnProtectTooling = false

        net.Start("props_NetworkAntinoobSpawnTool")
            net.WriteBool( false )
        net.Send( pl )

        if SERVER then
            pl:ChatPrint("Finished setting spawn protection. Run props_resetantinoob to reset.")
            props_SaveAntinoobSpawnProtection( pl.SpawnProtectPos1, trace.HitPos, pl )
        end
    else
        pl.SpawnProtectTooling = true
        pl.SpawnProtectPos1 = trace.HitPos
        net.Start("props_NetworkAntinoobSpawnTool")
            net.WriteBool( true )
            net.WriteVector( trace.HitPos )
        net.Send( pl )
    end
    return true
end

function TOOL:Reload(trace)
    if not PROPKILL.Config or not PROPKILL.Config["spawnprotection"] then return false end
    if not PROPKILL.Config["spawnprotection"].default then return false end

    if CLIENT then return true end

    local pl = self:GetOwner()
    pl.SpawnProtectTooling = false

    net.Start("props_NetworkAntinoobSpawnTool")
        net.WriteBool( false )
    net.Send( pl )

    if SERVER then
        pl:ChatPrint("Reset all spawn protection areas.")
        props_RemoveAntinoobSpawnProtectionEntry( "*", pl )
    end
end


if CLIENT then
    TOOL.Information =
    {
    {name = "left"},
    {name = "right"},
    {name = "reload"}
    }
    language.Add("Tool.spawnprotect.name", "Spawn Protect")
    language.Add("Tool.spawnprotect.desc", "Draw a box to protect spawn from noobs")
    language.Add("Tool.spawnprotect.left", "Left click: Add a point.")
    language.Add("Tool.spawnprotect.right", "Right click: Reset or remove spawn point.")
    language.Add("Tool.spawnprotect.reload", "Reload: Delete all spawn protection areas.")

    net.Receive("props_NetworkAntinoobSpawnTool", function()
        local FirstHit = net.ReadBool()
        local FirstHitPos = net.ReadVector()

        LocalPlayer().SpawnProtectTooling = FirstHit
        if FirstHit then
            LocalPlayer().SpawnProtectPos1 = FirstHitPos
        end
    end )

    net.Receive("props_NetworkAntinoobProtectionAreas", function()
        AntinoobSpawnProtectionAreas = {}

            -- max of 8 spawn protection areas
        local AreaCount = net.ReadUInt( 3 )
        for i=1,AreaCount do
            local Startpos = net.ReadVector()
            local Endpos = net.ReadVector()

            AntinoobSpawnProtectionAreas[ i ] = {startpos=Startpos, endpos=Endpos}
        end
    end )

    hook.Add("PostDrawTranslucentRenderables", "DrawSpawnProtectionArea", function()
        if LocalPlayer():GetTool() == nil or LocalPlayer():GetTool().Mode != "spawnprotect" then return end

        for i=1,#AntinoobSpawnProtectionAreas do
            local v = AntinoobSpawnProtectionAreas[i]

            --render.SetColorMaterial()
            render.DrawWireframeBox( Vector(0, 0, 0), Angle(0, 0, 0), v.startpos, v.endpos, Color(255,0,0,255), true )

                -- Draw the extended spawn area as well
            local center = (v.startpos + v.endpos) / 2
            local newmin = center + (v.startpos - center) * 1.3
            local newmax = center + (v.endpos - center) * 1.3
            render.DrawWireframeBox( Vector(0, 0, 0), Angle(0, 0, 0), newmin, newmax, Color(125,0,125,255), true )
        end

        if not LocalPlayer().SpawnProtectTooling or not LocalPlayer().SpawnProtectPos1 then return end

        render.SetColorMaterial()
        render.DrawWireframeBox( Vector(0, 0, 0), Angle(0, 0, 0),
            LocalPlayer().SpawnProtectPos1, LocalPlayer():GetEyeTrace().HitPos,
            Color(255,255,0,255), true
        )
    end)
elseif SERVER then
    function props_SaveAntinoobSpawnProtection( pos1, pos2, optional_pl )
        if pos1 and pos2 then
            AntinoobSpawnProtectionAreas[ #AntinoobSpawnProtectionAreas + 1 ] = {startpos=pos1, endpos=pos2}

            local trigger = ents.Create( "props_spawntrigger")
            trigger:SetPos( pos1 )
            trigger:SetKeyValue("mins", tostring(pos1))
            trigger:SetKeyValue("maxs", tostring(pos2))
            trigger:Spawn()
            trigger.SpawnProtectionAreaLinked = #AntinoobSpawnProtectionAreas
        end

        file.Write("props/spawnprotection/" .. game.GetMap():lower() .. ".txt", util.TableToJSON(AntinoobSpawnProtectionAreas))

        if optional_pl then
            net.Start("props_NetworkAntinoobProtectionAreas")
                    -- max of 8 spawn protection areas
                net.WriteUInt(#AntinoobSpawnProtectionAreas, 3)
                for i=1,#AntinoobSpawnProtectionAreas do
                    local v = AntinoobSpawnProtectionAreas[i]

                    net.WriteVector( v.startpos )
                    net.WriteVector( v.endpos )
                end
            net.Send(optional_pl)
        end
    end

    function props_RemoveAntinoobSpawnProtectionEntry( i, optional_pl )
        if i == "*" then
            AntinoobSpawnProtectionAreas = {}
            for k,v in next, ents.FindByClass("props_spawntrigger") do
                v:Remove()
            end
        else
            AntinoobSpawnProtectionAreas[ i ] = nil
            for k,v in next, ents.FindByClass("props_spawntrigger") do
                if v.SpawnProtectionAreaLinked and v.SpawnProtectionAreaLinked == i then
                    v:Remove()
                end
            end
        end
        props_SaveAntinoobSpawnProtection( nil, nil, optional_pl )
    end

end


    -- todo: add button to give toolgun (superadmin only)
function TOOL.BuildCPanel( CPanel )
    CPanel:Button( "Give Toolgun", "props_givetoolgun" )
    --[[local SpawnProtectionList = vgui.Create("DListView")
    for i=1,#AntinoobSpawnProtectionAreas do
        local v = AntinoobSpawnProtectionAreas[i]

        SpawnProtectionList:AddLine("Spawn Area #".. i)
    end

    CPanel:AddItem( SpawnProtectionList )]]
end
