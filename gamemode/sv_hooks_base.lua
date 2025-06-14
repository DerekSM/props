--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Hooks overwritten from sandbox / base gamemode.
]]--

local _R = debug.getregistry()

--[[

*

* Initializing of server / gamemode

*

--]]
function GM:InitPostEntity()
	local physData = physenv.GetPerformanceSettings()
		-- PEOPLE LIKE OTHER PK SETTINGS
	physData.MaxVelocity = 2200
	physData.MaxAngularVelocity = 3636
	physData.MaxCollisionsPerObjectPerTimestep = 100
	physData.LookAheadTimeObjectsVsObject = 1
	
	physenv.SetPerformanceSettings( physData )
	
		-- should these be managed by gamemode?
	game.ConsoleCommand( "sv_allowcslua 1\n" )
	game.ConsoleCommand( "sv_kickerrornum 0\n" )
	game.ConsoleCommand( "physgun_DampingFactor 0.9\n" )
	game.ConsoleCommand( "sv_sticktoground 0\n" )
	
		-- cvars designed for 66 tick servers
	game.ConsoleCommand( "sv_maxrate 20000\n")
	game.ConsoleCommand( "sv_maxupdaterate 66\n" )
		-- Don't auto-set sv_accelerate + sv_airaccelerate -- but add config options to change ingame.
		
		-- Removes entities not wanted in a propkilling environment.
	util.CleanUpMap( true )

		-- Unlocks all doors on the map. We don't default to removing doors; we leave that up to admins in config menu.
	for k,v in next, ents.GetAll() do
		if v:GetClass() == "prop_door_rotating" or v:GetClass() == "func_door_rotating" then
			v:Fire("unlock", "", 0)
		end
	end
	
		-- ulx player pickup
	hook.Remove( "PhysgunPickup", "ulxPlayerPickup" )
		-- saving MOTD until after credits
	hook.Remove( "PlayerInitialSpawn", "showMotd" )
	concommand.Remove( "gmod_admin_cleanup" )
end

function GM:Initialize()
	file.CreateDir( "props/achievements" )
	
	for k,v in next, properties.List do
		if v.Order < 2000 and k != "remove" then
			properties.List[ k ] = nil
		end
	end
	
	if file.Exists( "props/topplayers.txt", "DATA" ) then
		local data = pon.decode( file.Read( "props/topplayers.txt", "DATA" ) )
		
		PROPKILL.TopPlayers = data
	end
	
	if file.Exists( "props/statistics.txt", "DATA" ) then
		local data = pon.decode( file.Read( "props/statistics.txt", "DATA" ) )
		if data then
		
			PROPKILL.Statistics = data
		
		end
	end
	timer.Create( "props_SaveStatistics", 30, 0, function()
		file.Write( "props/statistics.txt", pon.encode( PROPKILL.Statistics ) )
	end )
	
	if file.Exists( "props/recentbattles.txt", "DATA" ) then
		local data = pon.decode( file.Read( "props/recentbattles.txt", "DATA" ) )
		
		PROPKILL.RecentBattles = data
	end
	
	if file.Exists( "props/topprops.txt", "DATA" ) then
		local data = pon.decode( file.Read( "props/topprops.txt", "DATA" ) )
		
		PROPKILL.TopPropsTotal = data
	end

	props_LoadGamemodeConfig()
	props_LoadCombatAchievements()
		
end

--[[

*

* Button handling

*

--]]
function GM:ShowTeam( pl )
	if pl.AntiMenuSpam and pl.AntiMenuSpam > CurTime() then
		return
	end
	
	pl:ConCommand( "props_menu" )
	pl.AntiMenuSpam = CurTime() + 0.3
end
function GM:ShowSpare1( pl )
	net.Start( "props_ShowClicker" )
	net.Send( pl )
end
function GM:ShowSpare2( pl )
	self:ShowTeam( pl )
end

--[[

*

* Player Spawning

*

--]]
function GM:PlayerInitialSpawn( pl )
	pl:SetTeam( TEAM_SPECTATOR )
	
	if pl:IsBot() then
		local random = math.random( 1, 7 )
		pl:SetTeam( random >= 6 and TEAM_RED or random == 1 and TEAM_BLUE or random == 2 and TEAM_BLUE or TEAM_DEATHMATCH )
	end
	
	for k,v in next, player.GetHumans() do
		PROPKILL.ChatText( v, PROPKILL.Colors.Blue, pl:Nick(), color_white, " has connected to the server. (", PROPKILL.Colors.Blue, pl:SteamID(), color_white, ")" )
	end
	
	pl:LoadCombatAchievements()
	pl:LoadPropkillData()
	
	timer.CreatePlayer( pl, "pk_SavePlayerData", 15, 0, function()
		pl:SavePropkillData()
	end )
	
	timer.CreatePlayer( pl, "props_NetworkUpdatedConfig", 5, 1, function()
		local tbl = table.Copy(PROPKILL.Config)
		for k,v in next, tbl do
			v.func = nil
		end
		
		net.Start( "props_UpdateFullConfig" )
			net.WriteTable( tbl )
		net.Send( pl )
	
		props_SendRecentBattles( pl )
	end )

	timer.CreatePlayer( pl, "SendBattleFix", 10, 1, function()
		if not PROPKILL.Battling then return end
		
		net.Start( "props_BattleInit" )
			net.WriteEntity( PROPKILL.Battlers[ "inviter" ] )
			net.WriteEntity( PROPKILL.Battlers[ "invitee" ] )
			
			net.WriteUInt( 0, 2 )
			net.WriteFloat( PROPKILL.ServerBattleTime )
		net.Send( pl )
	end )
	
	props_SendTopPropsTotal( pl )

	timer.CreatePlayer( pl, "SendUpdatedAchievements", 12, 1, function()
		Props_SendPlayerAllAchievementsCompleted( pl )
	end )
	
	PROPKILL.Statistics[ "totaljoins" ] = (PROPKILL.Statistics[ "totaljoins" ] or 0) + 1
	
	
		-- to the right, 1, -0, -0
		-- to the left, -1, 0, 0
		-- to the front, 0, 1, -0
		-- to the back, -0, -1, 0
		-- to the bottom, -0, 0, 1
		-- to the top, -0, 0, -1
	pl:AddCallback( "PhysicsCollide", function( ent, data )
		if not IsValid( data.HitEntity ) or data.HitEntity:GetClass() != "prop_physics" or not data.HitEntity.PropOwner then return end
		
			-- we don't care if it's the left, right, front, or back
		local normal = data.HitNormal
		
		if tostring(normal.z) == "-1" or normal.z >= 0.92 and normal.z <= 1 and ent:GetGroundEntity() != data.HitEntity then
			
			data.HitEntity.PropOwner.Headsmash = ent
				-- takes about 0.04 seconds to register the death
			timer.CreatePlayer( data.HitEntity.PropOwner, "props_ResetHeadsmash", 0.05, 1, function()
				if not IsValid( ent ) or not IsValid( data.HitEntity ) or not IsValid( data.HitEntity.PropOwner )
				or data.HitEntity.PropOwner.Headsmash != ent then return end
				
				data.HitEntity.PropOwner.Headsmash = nil
			end )
			
		end
	end )
end

function GM:PlayerSpawn( pl )
	if pl:Team() == TEAM_SPECTATOR then 
		pl:StripWeapons()
		pl:Spectate( OBS_MODE_ROAMING )
		return 
	end
	
	pl:UnSpectate()
	pl:SetWalkSpeed( 250 )
	pl:SetRunSpeed( 380 )
	pl:SetHealth( 1 )
		-- Matches sandbox/base gamemodes
	pl:SetJumpPower( 200 )
	pl:SetPlayerColor( Vector( pl:GetInfo( "cl_playercolor" ) ) )
	GAMEMODE:PlayerLoadout( pl )
	GAMEMODE:PlayerSetModel( pl )
	
	pl:AllowFlashlight( true )
	pl.DeathTime = nil
end

function GM:PlayerLoadout( pl )
	pl:StripWeapons()
	pl:Give( "weapon_physgun" )
	if pl:IsBot() then
		pl:SetWeaponColor( Vector( 2, 3, 5 ) )
	else
		pl:SetWeaponColor( Vector( pl:GetInfo( "cl_weaponcolor" ) ) )
	end
end

function GM:PlayerSetModel( pl )
	local cl_playermodel = pl:GetInfo( "cl_playermodel" )
	local translated = player_manager.TranslatePlayerModel( cl_playermodel )
		
	pl:SetModel( translated )
end

function GM:PlayerDisconnected( pl )
	pl:Cleanup()
	pl:SavePropkillData()

	if PROPKILL.Battling and PROPKILL.Battlers[ "inviter" ] == pl then
		GAMEMODE:EndBattle( pl, PROPKILL.Battlers[ "invitee" ], pl, nil, PROPKILL.Battlers[ "invitee" ]:Nick() )
	elseif PROPKILL.Battling and PROPKILL.Battlers[ "invitee" ] == pl then
		GAMEMODE:EndBattle( PROPKILL.Battlers[ "inviter" ], pl, pl, nil, PROPKILL.Battlers[ "inviter" ]:Nick() )
	end

	for k,v in next, player.GetHumans() do
		PROPKILL.ChatText( v, PROPKILL.Colors.Blue, pl:Nick(), color_white, " has left the server. (", PROPKILL.Colors.Blue, pl:SteamID(), color_white, ")" )
	end
end

--[[

*

* Player Damage / Deaths

*

--]]
function GM:PlayerDeath( pl, wep, killer )
	pl.NextSpawnTime = CurTime() + PROPKILL.Config[ "dead_respawndelay" ].default
	pl.DeathTime = CurTime()
end


local KillTypesAndColors =
{
	[ "longshot" ] = {"Longshot", Color( 190, 30, 220, 255 )},	-- light violet
	[ "flyby" ] = {"Flyby", Color( 20, 150, 100, 255 )},		-- blue-green
	[ "headsmash" ] = {"Headsmash", Color( 191, 255, 127, 255 )},	-- some gay color, shit green
	[ "smash" ] = {"Smash", Color( 255, 204, 0, 255 )},		-- yellow-orange
}
local function DoPlayerDeathCleanedUp( prop_owner, deadplayer, killtype, b_NoRecordingKillType )
	local hud_message = {}
	local message = table.FastConcat( "", prop_owner:Nick(), " ", killtype, "'d ", deadplayer:Nick() )

	hud_message = { txt = message, col = KillTypesAndColors[ killtype ][2] }
	if not PROPKILL.Battling and not b_NoRecordingKillType then
		_R.Player[ "Add" .. KillTypesAndColors[ killtype ][1] ]( prop_owner )
	end

	for k,v in player.Iterator() do
		v:ConsoleMsg( Color( 200, 100, 200, 255 ), message )
	end

	PROPKILL.Statistics[ "total" .. killtype ] = ( PROPKILL.Statistics[ "total" .. killtype ] or 0 ) + 1

	return killtype, hud_message
end

function GM:DoPlayerDeath( pl, killer, dmginfo )
	pl:CreateRagdoll()
	if not PROPKILL.Battling then
		pl:AddDeaths( 1 )
	end
	
	if PROPKILL.Config[ "dead_removeprops" ].default then
		pl:Cleanup()
	end

	local prop_owner = nil

	if killer:IsPlayer() then
		prop_owner = killer
		hook.Run("props_PropKilled", pl, dmginfo:GetInflictor())
	else
		prop_owner = killer.Owner and IsValid( killer.Owner ) and killer.Owner:IsPlayer() and killer.Owner or pl:GetNearestProp().Owner
			-- All these different hooks and methods and net calls are really piling up
			-- I need to clean up the whole gamemode
		hook.Run("props_PropKilled", pl, killer)
	end
	
	if not prop_owner and not PROPKILL.Battling then 
		pl:SetKillstreak( 0 )
		return
	end
	
	if prop_owner != pl then
		if not PROPKILL.Battling then
			if prop_owner:IsPlayer() then
				prop_owner:AddFrags( 1 )
				prop_owner:SetDeathstreak( 0 )
			end
			pl:AddDeathstreak( 1 )
		end
			-- rare bug
		if prop_owner:IsPlayer() then
			prop_owner:AddKillstreak( 1 )
		end
	else
		if PROPKILL.Battling then
			if pl:IsBattleInviter() then
				PROPKILL.Battlers[ "invitee" ]:AddKillstreak( 1 )
			else
				PROPKILL.Battlers[ "inviter" ]:AddKillstreak( 1 )
			end
		else
			PROPKILL.Statistics[ "totalsuicides" ] = (PROPKILL.Statistics[ "totalsuicides" ] or 0) + 1
			prop_owner:AddDeathstreak( 1 )
			prop_owner:SetKillstreak( 0 )
		end
	end
	
	local KillType, HUDMessage = "Smash", {}
	if prop_owner != pl then
		if prop_owner:GetPos():Distance( pl:GetPos() ) >= 4000 then
			KillType, HUDMessage = DoPlayerDeathCleanedUp( prop_owner, pl, "longshot" )
				-- We just did a double whammy. Call the hook SPECIFICALLY made for achievements
			if prop_owner.Headsmash and prop_owner.Headsmash == pl then
				hook.Run("props_DoubleWhammyLongshotHeadsmash", prop_owner, pl )
			end
		elseif prop_owner:IsFlying() then
			KillType, HUDMessage = DoPlayerDeathCleanedUp( prop_owner, pl, "flyby" )
		elseif prop_owner.Headsmash and prop_owner.Headsmash == pl then
			KillType, HUDMessage = DoPlayerDeathCleanedUp( prop_owner, pl, "headsmash" )
		else
			KillType, HUDMessage = DoPlayerDeathCleanedUp( prop_owner, pl, "smash", true )
		end
	end
	
	if GAMEMODE.KillingSprees and PROPKILL.Config["sounds_playkillingsprees"].default then
		local killingspree = GAMEMODE.KillingSprees
		local killstreak = prop_owner:GetKillstreak()
		if killingspree and killingspree[ killstreak ] and not PROPKILL.Battling then
			net.Start( "props_PlaySoundURL" )
				net.WriteString( killingspree[ killstreak ][ 2 ] )
			net.Broadcast()

			PrintMessage( HUD_PRINTCENTER, string.format( killingspree[ killstreak ][ 1 ], prop_owner:Nick() ) )
		end
	end
	
		-- Clients can use this data for themselves
		-- e.g writing a personal kill / death tracking script
	net.Start( "props_NetworkPlayerKill" )
			-- dead player
		net.WriteEntity( pl )
			-- killer
		net.WriteEntity( prop_owner )
		net.WriteString( KillType )
	net.Send( {pl, prop_owner} )
	
	if HUDMessage.txt then
		net.Start( "PK_HUDMessage" )
			net.WriteString( HUDMessage.txt )
			net.WriteUInt( HUDMessage.col.r, 8 )
			net.WriteUInt( HUDMessage.col.g, 8 )
			net.WriteUInt( HUDMessage.col.b, 8 )
		net.Broadcast()
	end
	
	net.Start( "PlayerKilled" )
		net.WriteEntity( pl )
		net.WriteString( prop_owner:GetClass() )
		net.WriteEntity( prop_owner )
	net.Broadcast()
	
	if not PROPKILL.Battling then
		pl:SetKillstreak( 0 )
		
		PROPKILL.Statistics[ "totalkills" ] = (PROPKILL.Statistics[ "totalkills" ] or 0) + 1
	end
	
	if PROPKILL.Battling then
		if PROPKILL.Battlers[ "inviter" ]:GetKillstreak() >= PROPKILL.BattleAmount then
			GAMEMODE:EndBattle( PROPKILL.Battlers[ "inviter" ], PROPKILL.Battlers[ "invitee" ], nil, nil, PROPKILL.Battlers[ "inviter" ]:Nick(), PROPKILL.Battlers[ "inviter" ]:GetKillstreak() .. " - " .. PROPKILL.Battlers[ "invitee" ]:GetKillstreak(), PROPKILL.Battlers[ "inviter" ]:Nick() .. " has won the fight! ( " .. PROPKILL.Battlers[ "inviter" ]:GetKillstreak() .. " - " .. PROPKILL.Battlers[ "invitee" ]:GetKillstreak() .. " )" )
		elseif PROPKILL.Battlers[ "invitee" ]:GetKillstreak() >= PROPKILL.BattleAmount then
			GAMEMODE:EndBattle( PROPKILL.Battlers[ "inviter" ], PROPKILL.Battlers[ "invitee" ], nil, nil, PROPKILL.Battlers[ "invitee" ]:Nick(), PROPKILL.Battlers[ "inviter" ]:GetKillstreak() .. " - " .. PROPKILL.Battlers[ "invitee" ]:GetKillstreak(), PROPKILL.Battlers[ "invitee" ]:Nick() .. " has won the fight! ( " .. PROPKILL.Battlers[ "inviter" ]:GetKillstreak() .. " - " .. PROPKILL.Battlers[ "invitee" ]:GetKillstreak() .. " )" )
		end
	end
	
end

--[[function GM:PlayerDeathThink( pl )

end]]

function GM:PlayerDeathSound()
	return true
end

function GM:PlayerHurt( pl, attacker, healthRemaining, damageTaken )
end

function GM:CanPlayerSuicide( pl )
	if PROPKILL.BattlePaused then
		pl:Notify( 1, 4, "You can't suicide while the battle is paused!" )
		return false
	end
	
	if pl:Team() == TEAM_SPECTATOR then
		return false
	end
	
	return true
end
	
--[[

*

* Entity Handling (Spawning, Manipulation)

*

--]]
local propsMaxProps = GetConVar( "sbox_maxprops" )
function GM:PlayerSpawnProp( pl, mdl )
	if pl:Team() == TEAM_SPECTATOR 
	or (not pl:Alive() and not PROPKILL.Config[ "dead_spawnprops" ].default) then
		local msg = true
		if pl.DeathTime and CurTime() - pl.DeathTime <= 0.75 then
			msg = false
		end
		
		if msg then
			pl:Notify( NOTIFY_ERROR, 3, "You must be alive to spawn props!", true )
		end
			
		return false
	end
	
		-- check if people are trying to bypass the list.
	if ( string.find( string.lower( mdl ), "\\/" )
	or string.find( string.lower( mdl ), "/\\" )
	or string.find( string.lower( mdl ), "/../" )
	or string.find( string.lower( mdl ), "\\../" )
	or string.find( string.lower( mdl ), "/..\\" ) )
	and not pl:IsSuperAdmin() then
		pl:Notify( NOTIFY_ERROR, 4, "Prop contains invalid characters." )
		return false
	end

		-- check if a model is blacklisted.
	if (PROPKILL.BlockedModels
	and PROPKILL.BlockedModels[ string.lower( mdl ) ])
	and PROPKILL.Config["blockedmodels"].default then
		if pl:IsSuperAdmin() then
			pl:ChatPrint( mdl .. " is normally blocked, however you are allowed to bypass the list." )
		else
			pl:Notify( NOTIFY_ERROR, 4, "This model is blacklisted" )
			return false
		end
	end
	
	if PROPKILL.HugeProps[ string.lower( mdl ) ] then
		pl:Notify( NOTIFY_ERROR, 4, "You can't spawn huge props!" )
		return false
	end

	if pl.Props and pl.Props >= propsMaxProps:GetInt() then
		pl:Notify( 1, 3, "Prop limit reached (" .. propsMaxProps:GetInt() .. ")!" )
		return false
	end
	
	if not PROPKILL.TopPropsCache[ string.lower( mdl ) ] then 
		PROPKILL.TopPropsCache[ string.lower( mdl ) ] = 0
	end
	PROPKILL.TopPropsCache[ string.lower( mdl ) ] = PROPKILL.TopPropsCache[ string.lower( mdl ) ] + 1
	
	return true
end

function GM:PlayerSpawnedProp( pl, mdl, ent )
	
	ent:SetSaveValue( "fademindist", 2560 )--256)
	ent:SetSaveValue( "fademaxdist", 10240 )--1024)
	
	PROPKILL.Statistics[ "propspawns" ] = PROPKILL.Statistics[ "propspawns" ] or 0
	PROPKILL.Statistics[ "propspawns" ] = PROPKILL.Statistics[ "propspawns" ] + 1
	
			--[[Do you know there is a way you can just set draw distance on every prop? No network is needed.

		ent:SetSaveValue("fademindist", 256)
		ent:SetSaveValue("fademaxdist", 1024)

		I have used it on my sanbox server and it is perfect when some construction grabbing my fps. 
		]]
		
	ent:SetNW2Entity( "Owner", pl )
	ent.PropOwner = pl
	
	if PROPKILL.Battling and PROPKILL.Battlers[ "inviter" ] == pl or PROPKILL.Battlers[ "invitee" ] == pl then
		pl:SetNWInt( "props_BattleProps", pl:GetNWInt( "props_BattleProps", 0 ) + 1 )
	end
	
end

function GM:PlayerSpawnVehicle( pl, mdl, vname, vtbl )
	pl:Notify( NOTIFY_ERROR, 1, 4, "You're not allowed to spawn this!" )
	return false
end

function GM:PlayerSpawnSWEP( pl )
	return pl:IsSuperAdmin()
end

function GM:PlayerGiveSWEP( pl )
	return pl:IsSuperAdmin()
end

function GM:PlayerSpawnSENT( pl, class )
	return pl:IsSuperAdmin()
end

function GM:PlayerSpawnRagdoll( pl, mdl )
	if pl:Team() == TEAM_SPECTATOR
	or (not pl:Alive() and not PROPKILL.Config[ "dead_spawnprops" ].default) then
		local msg = true
		if pl.DeathTime and CurTime() - pl.DeathTime <= 0.75 then
			msg = false
		end

		if msg then
			pl:Notify( NOTIFY_ERROR, 3, "You must be alive to spawn ragdolls!", true )
		end

		return false
	end

	return PROPKILL.Config[ "player_canspawnragdolls" ].default
end
function GM:PlayerSpawnedRagdoll( pl, model, ent )
	ent:SetNW2Entity( "Owner", pl )
	ent.PropOwner = pl
end

function GM:PlayerSpawnNPC( pl )
	return pl:IsSuperAdmin()
end

function GM:PlayerSpawnEffect( pl )
	pl:Notify( NOTIFY_ERROR, 1, 4, "You're not allowed to spawn this!" )
	return false
end

PROPKILL.MapDoorEntities = PROPKILL.MapDoorEntities or {}
	-- This function is important because it grabs ALL* key values set on the entity that :GetKeyValues doesn't necessarily grab.
	-- For doors this is only called on initial map load?
function GM:EntityKeyValue( ent, key, value )
		-- if door then store model, pos, angle
		-- for able to respawn at a later time.
	if ent:GetClass() == "func_door"
	or ent:GetClass() == "prop_door_rotating"
	or ent:GetClass() == "func_door_rotating" then

		PROPKILL.MapDoorEntities[ ent ] = PROPKILL.MapDoorEntities[ ent ] or {}
		PROPKILL.MapDoorEntities[ ent ][ key ] = value

	end
end

PROPKILL.StoredDoorEntities = PROPKILL.StoredDoorEntities or {}
function GM:EntityRemoved( ent )
		-- if door then store model, pos, angle
		-- for able to respawn at a later time.
	if ent:GetClass() == "func_door"
	or ent:GetClass() == "prop_door_rotating"
	or ent:GetClass() == "func_door_rotating" then
	
		print( "gm:entityremoved: doors" )
	
		PROPKILL.StoredDoorEntities[ #PROPKILL.StoredDoorEntities + 1 ] = { Class = ent:GetClass(), KeyValues = {} }
		if PROPKILL.MapDoorEntities[ ent ] then
			for k,v in next, PROPKILL.MapDoorEntities[ ent ] do
				PROPKILL.StoredDoorEntities[ #PROPKILL.StoredDoorEntities ]["KeyValues"][ k ] = v
			end
		end

		PROPKILL.MapDoorEntities[ ent ] = nil
		
	end
	
	if ent.Owner and IsValid(ent.Owner) and ent.Owner.Props and ent:GetClass() == "prop_physics" then
		ent.Owner.Props = ent.Owner.Props - 1
		if ent.Owner.Props < 0 then
			ent.Owner.Props = 0
		end
	elseif ent.Owner and IsValid(ent.Owner) and ent.Owner.Entities then
		--table.remove( ent.Owner.Entities, 
		--table.RemoveByValue( ent.Owner.Entities, ent )
		for k,v in ipairs( ent.Owner.Entities ) do
			if v == ent then
				v = NULL
			end
		end
	end
end

--[[

*

* Physgun

*

--]]
function GM:PhysgunPickup( pl, ent )
	if ent.Owner != pl then
		if string.find( ent:GetClass(), "playx" ) and pl:IsSuperAdmin() then
			return true
		else
			return false
		end
	end
	
	return true
end
function GM:OnPhysgunFreeze( wep, physobj, ent, pl )
	if ent.Owner != pl then
		if pl:IsSuperAdmin() then
			return true
		else
			return false
		end
	end
	
	return self.BaseClass:OnPhysgunFreeze( wep, physobj, ent, pl )
end
function GM:OnPhysgunReload( physgun, pl )
	return false
end

--[[

*

* Teams
*

--]]
function GM:PlayerCanJoinTeam( pl, teamid )
		--- check for if the team is in the team.GetList
		
	-- check team.GetAllTeams and Propkill.ValidTeams
	-- alternatively check for merging them into one table to check?

	if PROPKILL.Battling then
		return false, "There is a battle going on"
	end

	local timeSwitch = PROPKILL.Config["player_teamswitchdelay"].default

	if pl.LastTeamSwitch and (RealTime() - pl.LastTeamSwitch) <= 0 then
		return false, "Wait " .. math.Round( (pl.LastTeamSwitch - RealTime()), 1 ) .. " more seconds before trying again"
	end
	
	-- Already on this team!
	if pl:Team() == teamid then
		return false, "You're already on that team!"
	end

	pl.LastTeamSwitch = RealTime() + timeSwitch
	return true, "success"
end

--[[

*

* Misc

*

--]]
function GM:GetFallDamage( pl, speed )
	return 0
end

function GM:CanProperty( pl, property, ent )
	if property == "remover" and pl:IsSuperAdmin() and ent.Owner then
		for k,v in next, player.GetAll() do
			if v:IsAdmin() then
				v:ChatPrint( pl:Nick() .. " removed entity owned by " .. ent.Owner:Nick() )
			end
		end
		
		return true
	end
end

	-- add props to the origin?
	--  players will already be setting the area so props should be working where they are, hmmm
	--		maybe.

	-- lets you see players location at all times even when across map
function GM:SetupPlayerVisibility( pl )
		-- might be resource intensive doing this always.
		-- pretty sure if i stop doing this once the pvs is added that the players will keep drawing
		-- from that area...
		
		-- idea:
		--	each time PlayerInitialSpawn
		--		put into queue
		--			for 120 seconds keep calling below pvs, should capture most spots
		--				after 120 stop calling the below
	--[[for k,v in pairs( player.GetAll() ) do
		AddOriginToPVS( v:GetPos() )
	end]]
	
	if PROPKILL.Battling then
		if PROPKILL.BattlePlayerDormant and PROPKILL.BattlePropsDormant then
			return
		end
	end
	
	local tbl = {}
	
	tbl = ( PROPKILL.Battling and not PROPKILL.BattlePlayerDormant and table.Copy( player.GetAll() ) ) or not PROPKILL.Battling and table.Copy( player.GetAll() )
		-- TEMP AS OF 11/1/2015: Reenable after implementing votes or the fight options
	if PROPKILL.Battling and not PROPKILL.BattlePropsDormant then
		if #tbl == 0 then
			tbl = ents.FindByClass( "prop_physics" )
		else
			table.Add( tbl, ents.FindByClass( "prop_physics" ) )
		end
	end
	
	for k,v in pairs( tbl ) do
		if not v or not IsValid( v ) then continue end
		AddOriginToPVS( v:GetPos() )
	end
end

	-- Can even take this a step further and introduce exponential anti-spam
	-- But we won't do that unless requested
function GM:PlayerSay( pl, txt, teamchat )
	pl.LastChatTime = pl.LastChatTime or CurTime()
	pl.ChatHistory = pl.ChatHistory or {}

	if pl.LastChatTime > CurTime() then
		if pl.LastChatTime - PROPKILL.Config["player_chatdelay"].default > CurTime() then
			pl:PrintMessage(HUD_PRINTCONSOLE, "You've been chat limited. WAIT!")
		end
		return ""
	end

	if PROPKILL.Config["player_chatratelimit"].default then

			-- How far back are the past messages taken into account.
			-- We do a random integer to help prevent cheesing the system.
		local ChatWindowTimePeriod = math.random(7,11)
		for i=1,#pl.ChatHistory do
			local v = pl.ChatHistory[i]

			if CurTime() - v > ChatWindowTimePeriod then
				pl.ChatHistory[i] = nil
			end
		end

			-- They've triggered our anti-spam
		if #pl.ChatHistory > 5 then
			local MuteTime = PROPKILL.Config["player_chatratelimit_time"].default
			pl.LastChatTime = CurTime() + math.random(MuteTime, MuteTime + 3)
				-- Reset their history
			pl.ChatHistory = {}
			return ""
		end
	end

	pl.LastChatTime = CurTime() + PROPKILL.Config["player_chatdelay"].default
	table.insert( pl.ChatHistory, 1, CurTime() )

	PROPKILL.Statistics[ "totalmessages" ] = ( PROPKILL.Statistics[ "totalmessages" ] or 0 ) + 1
	hook.Run("props_PlayerSay", pl, txt, teamchat)
	return self.BaseClass:PlayerSay( pl, txt, teamchat )
end

--[[function GM:PlayerSay( pl, txt, teamchat )
	pl.LastChatTime = pl.LastChatTime or CurTime()
	if pl.LastChatTime > CurTime() then return "" end
	
		-- It's really not as bad as it looks
		-- The default delay in gmod is like 0.9 seconds
	pl.LastChatTime = CurTime() + 1.25
	
	PROPKILL.Statistics[ "totalmessages" ] = ( PROPKILL.Statistics[ "totalmessages" ] or 0 ) + 1
	hook.Run("props_PlayerSay", pl, txt, teamchat)
	return self.BaseClass:PlayerSay( pl, txt, teamchat )
end]]
