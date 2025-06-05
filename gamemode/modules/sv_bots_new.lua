--[[
				  _________.__    .__
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     /
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/
						\/      \/        \/\/         \/

		Makes bots follow a certain path and spawn props to simulate a propkilling environment

		... really all they do is prop surf around the map to allow players to practice
]]--

-- (Done) Todo: config setting to allow non admins to create paths and/or load bots
-- (Done) Todo: bot menu. And in this menu allow for selecting active paths to use.
-- Todo: strip the end of the bot pathing if there's no movements/buttons
-- (Done) Todo: Rewrite (After finished) to just use one command to start/stop. Start recording on first movement/button
-- (Done) Todo: Fix bot animation if theyre walking on ground. CalcMainActivity didnt seem to work too well...
-- Todo: HUD Popup timer showing how long the player has left to record.
-- (Done) Todo: Save the creator of the bot path. Maybe we want to reference it later who knows.
-- (Done) Todo: Make config setting to choose between using new bot paths or legacy system.
-- (Done) Todo: Make config setting for maximum recording time.
-- (Done) Todo: Fix paths that are created and saved without any actual movement data.

    -- 0 = None, 1 = Ray check, 2 = Bounding box check
    -- I ~assume~ (didnt test) that bounding box check is most intensive
local AdditionalPhysicsCollideCheck = 2


util.AddNetworkString("props_BotPaths_NetworkAllPaths")
util.AddNetworkString("props_BotPaths_NetworkPath")
util.AddNetworkString("props_BotPaths_TogglePaths")
util.AddNetworkString("props_BotPaths_RequestFullUpdate")
util.AddNetworkString("props_BotPaths_NetworkRecording")

props_BotEnabled2 = props_BotEnabled2 or false
hook.Add( "InitPostEntity", "props_BotSurfCheckMap2", function()
	file.CreateDir( "props/botpaths2" )

	if file.Exists( "props/botpaths2/" .. string.lower( game.GetMap() ) .. ".txt", "DATA" ) then
		BOTPATHS_RECORDINGS = pon.decode( file.Read( "props/botpaths2/" .. string.lower( game.GetMap() ) .. ".txt" ) )
	else
		props_BotEnabled2 = false
	end
end )

BOTPATHS_RECORDINGS = BOTPATHS_RECORDINGS or {}
BOTPATHS_RECORDINGSINPROGRESS = BOTPATHS_RECORDINGSINPROGRESS or {}


local function BotPaths_PlayerForceStop( pl )
    BOTPATHS_RECORDINGSINPROGRESS[ pl.RecordMovement2 ] = false
    if BOTPATHS_RECORDINGS[ pl.RecordMovement2 ] then
        BOTPATHS_RECORDINGS[ pl.RecordMovement2 ].ActivePath = true
    end
	pl.RecordMovement2 = nil
	pl:ChatPrint( "stopped" )

	if timer.HasPlayer( pl, "botpaths_startstop" ) then
        timer.DestroyPlayer( pl, "botpaths_startstop" )
    end
end

    -- Edge case: We have to stop all players that are re-recording a path with the same name.
local function BotPaths_DeleteSavedPath( pathid )
    BOTPATHS_RECORDINGS[ pathid ] = nil

    if BOTPATHS_RECORDINGSINPROGRESS[ pathid ] then
        for k,v in next, player.GetHumans() do
            if pl.RecordMovement2 == pathid then
                BotPaths_PlayerForceStop( v )
            end
        end
    end
    for k,v in next, player.GetBots() do
        if v.ReplayMovement2 and v.ReplayMovement2 == pathid then
            v.ReplayTable2 = nil
            v.ReplayMovement2 = nil
            v:Kill()
        end
    end
end

local function BotPaths_NetworkPaths( pl )
    net.Start("props_BotPaths_NetworkAllPaths")
        net.WriteUInt( table.Count(BOTPATHS_RECORDINGS), 5 )
        for k,v in next, BOTPATHS_RECORDINGS do
            net.WriteString( k )
            net.WriteBool( v.ActivePath )
            net.WriteUInt64( v.Creator )
            net.WriteUInt( v.CreatorTime, 32 )
        end
    net.Send( pl )
end

    -- Specifically this is just for removing a path
local function BotPaths_NetworkRemovedPath( pl, pathid )
    net.Start("props_BotPaths_NetworkPath")
        net.WriteString( pathid )
    net.Send( pl )
end
net.Receive( "props_BotPaths_RequestFullUpdate", function( len, pl )
    if pl.BotPaths_FullyUpdated then return end

    BotPaths_NetworkPaths( pl )
    pl.BotPaths_FullyUpdated = true
end )

hook.Add("PlayerChangedTeam", "props_InvalidateRecording", function( pl )
    if not pl.RecordMovement2 or not BOTPATHS_RECORDINGS[ pl.RecordMovement2 ] then return end


	BOTPATHS_RECORDINGS[ pl.RecordMovement2 ] = nil
	BotPaths_PlayerForceStop( pl )
end )

    -- Edge case
hook.Add("props_BattleStarted", "props_InvalidateRecording", function()
    for k,v in next, player.GetHumans() do
        if not v.RecordMovement2 or not BOTPATHS_RECORDINGS[ v.RecordMovement2 ] then continue end

        BOTPATHS_RECORDINGS[ v.RecordMovement2 ] = nil
        BotPaths_PlayerForceStop( v )
    end
end )

hook.Add( "ShouldCollide", "props_StopBotsFreezingInEachOther", function( pl1, pl2 )
    if pl1:IsPlayer() and pl2:IsPlayer() then
        if pl1:IsBot() and pl2:IsBot() then
            return false
        end
    end
end )

    -- Hook mostly copy pasted from old sv_bots.lua - MAY need to redo
hook.Add("PlayerSpawn", "props_ReplayPlayerMovement", function( pl )
    if pl:IsBot() and PROPKILL.Config[ "bots_enable" ] and PROPKILL.Config[ "bots_enable" ].default then


        local UsableRecordings = {}
        for k,v in next, BOTPATHS_RECORDINGS do
            if v.ActivePath then
                UsableRecordings[ k ] = v
            end
        end
        --local values, key = table.Random( BOTPATHS_RECORDINGS )
        local values, key = table.Random( UsableRecordings )
        if not key then return end
        pl.ReplayMovement2 = key
        --pl.ReplayTable2 = table.Copy( BOTPATHS_RECORDINGS[ pl.ReplayMovement2 ] )
        pl.ReplayTable2 = table.Copy( UsableRecordings[ pl.ReplayMovement2 ] )

        --print( pl.ReplayMovement2, pl:Nick() )
        if not pl.ReplayTable2[ "startpos" ] then return end
        pl:SetCustomCollisionCheck( true )
        pl:SetPos( pl.ReplayTable2[ "startpos" ] )
        pl:SetEyeAngles( pl.ReplayTable2[ "starteyes" ] )
        pl.ReplayTrigger2 = false
        pl.ReplayTable2[ "replayingpos" ] = 1
        timer.CreatePlayer( pl, "props_ReplayPlayerMovement", 0.1, 1, function()
            if not IsValid( pl ) then return end

            pl.ReplayTrigger2 = true
        end )

            -- The callback stuff can be changed later on. For now, its debugging.
        if pl.HasCallback2 then
            pl:RemoveCallback("PhysicsCollide", pl.HasCallback2)
        end
        local CallbackID = pl:AddCallback( "PhysicsCollide", function( ent, data )
            if not pl.ReplayMovement2 then return end
            if not BOTPATHS_RECORDINGS[ pl.ReplayMovement2 ] then print("no??") return end
            if not pl.ReplayTable2 then print( "no replay table, l-191" ) return end
            if pl:HasGodMode() then print("godmode") return end
            pl.ReplayTable2[ "replayingpos" ] = 0
            pl.ReplayMovement2 = nil

            timer.CreatePlayer( pl, "respawnbot", 1.5, 1, function()
                if not pl.ReplayMovement2 and PROPKILL.Config[ "bots_enable" ].default then
                    pl:Kill()
                end
            end )

            if data.HitEntity:GetClass() == "prop_physics" and data.TheirOldVelocity:Length() >= 1500 and not data.HitEntity:IsPlayerHolding() then
                print("damage??")
                pl:TakeDamage( pl:Health(), data.HitEntity, data.HitEntity )
            else
                    -- Got a warning about "Changing collision rules within a callback is likely to cause crashes!"
                    -- when it was right after .ReplayMovement2 = nil
                pl:SetMoveType( MOVETYPE_WALK )
            end
        end )

        pl.HasCallback2 = CallbackID
	end
end )

hook.Add("DoPlayerDeath", "props_ReplayPlayerMovementOrStopRecording", function( pl )
        -- If a player dies while recording we stop the recording. Simple
    if not pl:IsBot() and pl.RecordMovement2 and BOTPATHS_RECORDINGS[ pl.RecordMovement2 ] then
        BotPaths_PlayerForceStop( pl )
    elseif pl:IsBot() and pl.ReplayMovement2 then
        if not BOTPATHS_RECORDINGS[ pl.ReplayMovement2 ] then return end

        pl.ReplayTable2[ "replayingpos" ] = 0
        pl.ReplayMovement2 = nil
        pl.ReplayTable2 = {}
        timer.DestroyPlayer( pl, "props_ReplayPlayerMovement" )
    end
end )


   -- The SetupMove hook will be our new way of recording and replaying angles and positions.
    -- Prior version used PlayerTick for everything
hook.Add("SetupMove", "props_RecordPlayerMovementAndPlayBotMovement", function( pl, mv )
    if not pl:IsBot() and pl.RecordMovement2 and BOTPATHS_RECORDINGS[ pl.RecordMovement2 ] then

        if #BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "movedata" ] == 0 and
        not BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "startedrecording" ]then
            if mv:GetOrigin() == BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "startpos" ]
            and mv:GetAngles() == BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "starteyes" ] then

                    -- Player hasn't DONE anything yet. Don't start recording.
                return
            else
                --print("Start recording ;)")
                BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "startedrecording" ] = true

                    -- Start recording on our NEXT frame. (Is this necessary? Idk)
                return
            end
        end

        local RecordingFrame = #BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "movedata" ]
        BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "movedata" ][ RecordingFrame + 1 ] =
        {
            origin = mv:GetOrigin(),
            eyes = mv:GetAngles(),
        }

        -- Additional check ?maybe
    elseif pl:IsBot() and pl.ReplayMovement2 then
        if not BOTPATHS_RECORDINGS[ pl.ReplayMovement2 ] then return end
        if not pl:Alive() then pl:Spawn() end
        if not pl.ReplayTrigger2 then return end

            -- Setting the movetype to none fixes any kind of straggling walking animation artifacts
        pl:SetMoveType( MOVETYPE_NONE )

        local replaying_pos = pl.ReplayTable2[ "replayingpos" ]

        if not (pl.ReplayTable2[ "movedata" ][ replaying_pos + 1 ]) then
            --pl:ChatPrint( "finished" )
            pl:Spawn()
        end

            -- Since I guess the way we either record and/or playback is FUCKED and bots replay at ~2x the speed,
            -- we'll just duplicate the entries each frame to slow them down
            -- And we can't change the way we store data to maintain backwards compatibility
        if pl.ReplayedTheReplay and pl.ReplayTable2[ "replayingpos" ] != 0 then
            pl.ReplayTable2[ "replayingpos" ] = pl.ReplayTable2[ "replayingpos" ] + 1
            pl.ReplayedTheReplay = false
        else
            pl.ReplayedTheReplay = true
        end
        local replaymovement = pl.ReplayTable2

        --Print(replaymovement)

        local ReplayPosition = replaymovement[ "replayingpos" ]
        mv:SetOrigin( replaymovement[ "movedata" ][ ReplayPosition ].origin )
            -- neccesary for when the bot FLINGS PROPS AT YOU SON
        mv:SetMoveAngles( replaymovement[ "movedata" ][ ReplayPosition ].eyes )
        if not pl.LookingAtPlayer2 then
            pl:SetEyeAngles( replaymovement[ "movedata" ][ ReplayPosition ].eyes )
        end


        if AdditionalPhysicsCollideCheck > 0 then
                -- As long as there's a next entry
            if pl.ReplayTable2[ "movedata"][ ReplayPosition + 1 ] then


                local Entities = nil

                if AdditionalPhysicsCollideCheck == 1 then

                        -- Then look ahead
                        -- It's still not perfect but it will help to make the bots more realistic
                    Entities = ents.FindAlongRay(
                        mv:GetOrigin(),
                        pl.ReplayTable2[ "movedata"][ ReplayPosition + 1 ].origin
                    )

                elseif AdditionalPhysicsCollideCheck == 2 then
                        -- Test method 2
                    Entities = ents.FindInBox(
                        pl.ReplayTable2[ "movedata"][ ReplayPosition + 1 ].origin,
                        pl.ReplayTable2[ "movedata"][ ReplayPosition + 1 ].origin + select(2, pl:GetCollisionBounds())
                    )
                    -- local hitPos, hitNormal, frac = util.IntersectRayWithOBB( ply:GetShootPos(), ply:GetAimVector() * 500, ent:GetPos() + ent:OBBCenter(), ent:GetAngles(), ent:OBBMins(), ent:OBBMaxs() )
                end

                for i=1,#Entities do
                    local v = Entities[i]

                        -- If we found a prop then act like we PhysicsCollide'd
                    if v:GetClass() == "prop_physics" and IsValid(v:GetPhysicsObject()) then
                        --print2(Entities)
                        pl.ReplayTable2[ "replayingpos" ] = 0
                        pl.ReplayMovement2 = nil
                        pl:SetMoveType( MOVETYPE_WALK )

                        timer.CreatePlayer( pl, "respawnbot", 1.5, 1, function()
                            if not pl.ReplayMovement2 and PROPKILL.Config[ "bots_enable" ].default then
                                pl:Kill()
                            end
                        end )

                        if v:GetPhysicsObject():GetVelocity():Length() >= 1500 and not v:IsPlayerHolding() then
                            print("damage??")
                            pl:TakeDamage( pl:Health(), v, v )
                        end
                    end
                end

            end

        end

    end
end)

    -- The StartCommand hook is going to be specifically for buttons
hook.Add("StartCommand", "props_RecordPlayerMovementAndPlayBotMovement", function( pl, cmd )
    if not pl:IsBot() and pl.RecordMovement2 and BOTPATHS_RECORDINGS[ pl.RecordMovement2 ] then

        if #BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "buttons" ] == 0 and
        not BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "startedrecording" ] then
            if cmd:GetButtons() == 0 then

                    -- Player hasn't DONE anything yet. Don't start recording.
                return
            else

                --print("Start recording ;)")
                BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "startedrecording" ] = true

                    -- Start recording on our NEXT frame. (Is this necessary? Idk)
                return
            end
        end

        --BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "buttons" ][ #BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "buttons" ] + 1 ] = cmd:GetButtons()
        BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "buttons" ][ #BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "buttons" ] + 1 ] =
            {
            buttons = cmd:GetButtons(),
            forwardmove = cmd:GetForwardMove(),
            sidemove = cmd:GetSideMove(),
            --upmove = cmd:GetUpMove()
            }

        -- Additional check ?maybe
        -- Mostly copy pasted from old sv_bots.lua: MAY need to recode
    elseif pl:IsBot() and pl.ReplayMovement2 then
        if not BOTPATHS_RECORDINGS[ pl.ReplayMovement2 ] then return end
        if not pl:Alive() then pl:Spawn() end
        if not pl.ReplayTrigger2 then return end

            -- in theory? this should be better maybe but it breaks animations
        --cmd:ClearButtons()
        --cmd:ClearMovement()

        local replaying_pos = pl.ReplayTable2[ "replayingpos" ]
            -- SetupMove will handle resetting
        if not (pl.ReplayTable2[ "buttons" ][ replaying_pos + 1 ]) then return end

        pl.ReplayTable2[ "replayingpos" ] = pl.ReplayTable2[ "replayingpos" ]  + 1
        local replaymovement = pl.ReplayTable2

        local ReplayButtons = replaymovement[ "buttons" ][ replaymovement[ "replayingpos" ] ]
        cmd:SetButtons( ReplayButtons.buttons )
        cmd:SetForwardMove( ReplayButtons.forwardmove )
        cmd:SetSideMove( ReplayButtons.sidemove )
        --cmd:SetUpMove( ReplayButtons.upmove )
    end
end)

    -- todo: Should we let players/admins overwrite existing pathings?
concommand.Add( "props_botpaths_startstop", function( pl, cmd, arg )
    if not IsValid( pl ) then return end
    if not pl:IsAdmin() and PROPKILL.Config["bots_adminonly"].default then pl:ChatPrint("admin only") return end
    if not pl:Alive() or pl:Team() == TEAM_SPECTATOR then return end
    if PROPKILL.Config["bots_legacybots"].default then return end
        -- Arbitrary limit. If modified, you must edit the networking as well.
    if table.Count(BOTPATHS_RECORDINGS) >= 32 then
        pl:ChatPrint( "Delete some bot paths before making more")
        return
    end

        -- We are recording, stop it.
    if pl.RecordMovement2 then
            -- Tell them they're done recording so their menu can update
        net.Start("props_BotPaths_NetworkRecording")
            net.WriteString(pl.RecordMovement2)
            net.WriteBool(false)
        net.Send( pl )

        if #BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "movedata" ] > 0 and #BOTPATHS_RECORDINGS[ pl.RecordMovement2 ][ "buttons" ] > 0 then
            BotPaths_PlayerForceStop( pl )
            BotPaths_NetworkPaths( player.GetAll() )
        else
            pl:ChatPrint("Empty movement data. Not saving bot path.")
            BOTPATHS_RECORDINGS[ pl.RecordMovement2 ] = nil
            BotPaths_PlayerForceStop( pl )
        end
    else
        local BotPath = string.lower(arg[1] or os.date("%Y%b%d-%H%M", os.time()))

        if BOTPATHS_RECORDINGSINPROGRESS[ BotPath ] then
            pl:ChatPrint("There is already an active recording for that path. Try another.")
            return
        end

        BOTPATHS_RECORDINGS[ BotPath ] = BOTPATHS_RECORDINGS[ BotPath ] or {}
        BOTPATHS_RECORDINGS[ BotPath ][ "replayingpos" ] = 0
        BOTPATHS_RECORDINGS[ BotPath ][ "startpos" ] = pl:GetPos()
        BOTPATHS_RECORDINGS[ BotPath ][ "starteyes" ] = pl:EyeAngles()
        BOTPATHS_RECORDINGS[ BotPath ][ "buttons" ] = {}
        BOTPATHS_RECORDINGS[ BotPath ][ "movedata" ] = {}
            -- Triggered once they first move
        BOTPATHS_RECORDINGS[ BotPath ][ "startedrecording" ] = false
        BOTPATHS_RECORDINGS[ BotPath ][ "ActivePath" ] = false
        BOTPATHS_RECORDINGS[ BotPath ][ "Creator" ] = pl:SteamID64()
        BOTPATHS_RECORDINGS[ BotPath ][ "CreatorTime" ] = os.time()

        pl.RecordMovement2 = BotPath
        BOTPATHS_RECORDINGSINPROGRESS[ BotPath ] = true

        pl:ChatPrint( "Started recording \"" .. BotPath .. "\". To CANCEL, run props_botpaths_cancel" )
        pl:ChatPrint( "Recording starts on your first movement." )

        local TimeToRecord = PROPKILL.Config["bots_maxrecordingtime"].default
        pl:ChatPrint( string.format("You have %i seconds to finish recording your path.", TimeToRecord) )

        timer.CreatePlayer( pl, "botpaths_startstop", TimeToRecord, 1, function()
            BotPaths_PlayerForceStop( pl )
            BotPaths_NetworkPaths( player.GetAll() )

                -- Tell them they're done recording so their menu can update
            net.Start("props_BotPaths_NetworkRecording")
                net.WriteString("")
                net.WriteBool(false)
            net.Send( pl )
        end )

            -- Tell them they're recording so their menu can update
        net.Start("props_BotPaths_NetworkRecording")
            net.WriteString(BotPath)
            net.WriteBool(true)
        net.Send( pl )
    end
end )

concommand.Add( "props_botpaths_cancel", function( pl )
    if not IsValid( pl ) then return end
    --if not pl:IsAdmin() then pl:ChatPrint("admin only") return end
    if not pl.RecordMovement2 or not BOTPATHS_RECORDINGS[ pl.RecordMovement2 ] then return end
    if PROPKILL.Config["bots_legacybots"].default then return end

        -- Tell them they're done recording so their menu can update
    net.Start("props_BotPaths_NetworkRecording")
        net.WriteString(pl.RecordMovement2)
        net.WriteBool(false)
    net.Send( pl )
    BOTPATHS_RECORDINGS[ pl.RecordMovement2 ] = nil
    BotPaths_PlayerForceStop( pl )
end )

concommand.Add( "props_botpaths_save2", function( pl )
    if not pl:IsSuperAdmin() then return end
    if PROPKILL.Config["bots_legacybots"].default then return end

    file.Write( "props/botpaths2/" .. string.lower( game.GetMap() ) .. ".txt", pon.encode( BOTPATHS_RECORDINGS ) )
    pl:Notify( NOTIFY_GENERIC, 8, "Saved bot paths.", true )
end )

concommand.Add( "props_botpaths_reset", function( pl, cmd, arg )
    if not IsValid( pl ) then return end
    if PROPKILL.Config["bots_legacybots"].default then return end
    if not pl:IsSuperAdmin() then pl:ChatPrint("admin only") return end
    if not arg[1] or not arg[1] == "yes" then
        pl:ChatPrint( "This will reset ALL bot paths. Use argument 'yes' to continue.")
        return
    end

    BOTPATHS_RECORDINGS = {}
    BOTPATHS_RECORDINGSINPROGRESS = {}
    for k,v in next, player.GetHumans() do
        v.RecordMovement2 = nil
    end
    for k,v in next, player.GetBots() do
        v.ReplayTable2 = nil
        v.ReplayMovement2 = nil
    end

    file.Write( "props/botpaths2/" .. string.lower( game.GetMap() ) .. ".txt", pon.encode( BOTPATHS_RECORDINGS ) )
    pl:ChatPrint("You have deleted all bot paths and invalidated all current recordings.")
    BotPaths_NetworkPaths( player.GetAll() )
end )

concommand.Add( "props_botpaths_deletepath", function( pl, cmd, arg )
    if not IsValid( pl ) then return end
    if not pl:IsAdmin() and PROPKILL.Config["bots_adminonly"].default then pl:ChatPrint("admin only") return end
    if not arg[1] then return end
    if PROPKILL.Config["bots_legacybots"].default then return end

    local BotPath = string.lower(arg[1])
    if BOTPATHS_RECORDINGS[BotPath] then
        BotPaths_DeleteSavedPath( BotPath )
        pl:ChatPrint("Deleted Path " .. BotPath )
    end
    BotPaths_NetworkRemovedPath( player.GetAll(), BotPath )
end )

concommand.Add( "props_botpaths_togglepath", function( pl, cmd, arg )
    if not IsValid( pl ) then return end
    if not pl:IsAdmin() and PROPKILL.Config["bots_adminonly"].default then pl:ChatPrint("admin only") return end
    if not arg[1] then return end
    if PROPKILL.Config["bots_legacybots"].default then return end

    local BotPath = string.lower(arg[1])
    if BOTPATHS_RECORDINGS[BotPath] and BOTPATHS_RECORDINGS[BotPath].ActivePath then
        BOTPATHS_RECORDINGS[BotPath].ActivePath = false
            -- Kill all active bots using this path
        for k,v in next, player.GetBots() do
            if v.ReplayMovement2 and v.ReplayMovement2 == BotPath then
                v.ReplayTable2 = nil
                v.ReplayMovement2 = nil
                v:Kill()
            end
        end

        BotPaths_NetworkPaths( player.GetAll() )
    elseif BOTPATHS_RECORDINGS[BotPath] and not BOTPATHS_RECORDINGS[BotPath].ActivePath then
        BOTPATHS_RECORDINGS[BotPath].ActivePath = true

        BotPaths_NetworkPaths( player.GetAll() )
    end
end)

concommand.Add( "props_botpaths_spawnbot", function( pl )
    if not IsValid( pl ) then return end
    if not PROPKILL.Config["bots_allowspawning"].default then return end
    if PROPKILL.Config["bots_legacybots"].default then return end
    if not pl:IsAdmin() and PROPKILL.Config["bots_adminonly"].default then
        pl:ChatPrint("admin only")
        return
    end

    RunConsoleCommand("bot")
end )
