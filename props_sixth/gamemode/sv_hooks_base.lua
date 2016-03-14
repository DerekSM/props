--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Hooks overwritten from sandbox / base gamemode.
]]--


--[[

*

* Initializing of server / gamemode

*

--]]
function GM:InitPostEntity()
	local physData = physenv.GetPerformanceSettings()
		-- 2000
		-- 2250 - faster than pk 1.1; a little too fast.
		-- 2175 - a lot slower, but with the sv_accelerate changes i feel 2100 is perfect.
	physData.MaxVelocity = 2120
	physData.MaxAngularVelocity	= 3636
	
	physenv.SetPerformanceSettings( physData )
	
		-- should these be managed by gamemode?
	game.ConsoleCommand( "sv_allowcslua 1\n" )
	game.ConsoleCommand( "sv_kickerrornum 0\n" )
	game.ConsoleCommand( "physgun_DampingFactor 0.9\n" )
	game.ConsoleCommand( "sv_sticktoground 0\n" )
		-- Don't auto-set sv_accelerate + sv_airaccelerate -- but add config options to change ingame.
		
		-- Removes entities not wanted in a propkilling environment.
	util.CleanUpMap( true )
	
		-- ulx player pickup
	hook.Remove( "PhysgunPickup", "ulxPlayerPickup" )
		-- saving MOTD until after credits
	hook.Remove( "PlayerInitialSpawn", "showMotd" )
	concommand.Remove( "gmod_admin_cleanup" )
end

function GM:Initialize()
	file.CreateDir( "props" )
	
	for k,v in pairs( properties.List ) do
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
		
		PROPKILL.Statistics = data
	end
	timer.Create( "props_SaveStatistics", 30, 0, function()
		file.Write( "props/statistics.txt", pon.encode( PROPKILL.Statistics ) )
	end )
		
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
	--pl:SetTeam( TEAM_DEATHMATCH )
	
	if pl:IsBot() then
		local random = math.random( 1, 5 )
		pl:SetTeam( random >= 4 and TEAM_RED or random == 1 and TEAM_BLUE or TEAM_DEATHMATCH )
		random = math.random( 1, 6 )
		if random == 4 then
			pl:SetTeam( TEAM_DEATHMATCH )
			--pl:SetTeam( TEAM_SPECTATOR )
		end
	end
	
	--[[pl:InstallDataTable()
	pl:NetworkVar( "Int", 0, "TotalFrags" )
	pl:NetworkVar( "Int", 1, "TotalDeaths" )
	pl:NetworkVar( "Int", 2, "Killstreak" )
	pl:NetworkVar( "Int", 3, "BestKillstreak" )
	pl:NetworkVar( "Int", 4, "Flybys" )
	pl:NetworkVar( "Int", 5, "Longshots" )]]
	--pl:NetworkVar( "Float", 0, "Accuracy" )
	
	--player_manager.SetPlayerClass( pl, "player_propkill" )
	--player_manager.RunClass( pl, "Spawn" )
	
	for k,v in next, player.GetAll() do
		PROPKILL.ChatText( v, PROPKILL.Colors.Blue, pl:Nick(), color_white, " has connected to the server. (", PROPKILL.Colors.Blue, pl:SteamID(), color_white, ")" )
	end
	
	pl:ConsoleMsg( Color( 255, 127, 127, 255 ), "Welcome to " .. GAMEMODE.Name .. " - Created by Shinycow" )
	
	pl:LoadPropkillData()
	
	timer.Create( "pk_SavePlayerData" .. pl:UserID(), 15, 0, function()
		if not IsValid( pl ) then return end
		
		pl:SavePropkillData()
	end )

	--[[net.Start( "props_NetworkPlayerTotals" )
		net.WriteEntity( pl )
		net.WriteFloat( pl:Accuracy() )
		net.WriteUInt( pl:TotalFrags(), 20 )
		net.WriteUInt( pl:TotalDeaths(), 20 )
	net.Broadcast()
	
		-- player hasn't loaded yet.
	timer.Create( "props_NetworkPlayerTotals" .. pl:UserID(), 5, 1, function()
		if not IsValid( pl ) then return end

		net.Start( "props_NetworkPlayerTotals" )
			net.WriteEntity( pl )
			net.WriteFloat( pl:Accuracy() )
			net.WriteUInt( pl:TotalFrags(), 20 )
			net.WriteUInt( pl:TotalDeaths(), 20 )
		net.Send( pl )
	end )]]
end

function GM:PlayerSpawn( pl )
	if pl:Team() == TEAM_SPECTATOR then 
		pl:StripWeapons()
		pl:Spectate( OBS_MODE_ROAMING )
		return 
	end
	
	--player_manager.SetPlayerClass( pl, "player_propkill" )
	--player_manager.RunClass( pl, "Spawn" )
	
	pl:UnSpectate()
	pl:SetWalkSpeed( 250 )
	pl:SetRunSpeed( 380 )
	pl:SetHealth( 1 )
	pl:SetPlayerColor( Vector( pl:GetInfo( "cl_playercolor" ) ) )
	GAMEMODE:PlayerLoadout( pl )
	GAMEMODE:PlayerSetModel( pl )
	
	pl:AllowFlashlight( true )
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
	
	timer.Destroy( "pk_SavePlayerData" .. pl:UserID() )

	for k,v in next, player.GetAll() do
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
	
		-- it never seems to be worldspawn...
	if killer == Entity(0) then
		prop_owner = pl:GetNearestProp().Owner
	elseif killer:GetClass() == "prop_physics" and killer.Owner then
		prop_owner = killer.Owner
	elseif killer:IsPlayer() then
		prop_owner = killer
	end
	
	if not prop_owner and not PROPKILL.Battling then 
		pl:SetKillstreak( 0 )
		return
	end
	
	if prop_owner != pl then
		if not PROPKILL.Battling then
			prop_owner:AddFrags( 1 )
		end
		prop_owner:AddKillstreak( 1 )
	else
		if PROPKILL.Battling then
			if PROPKILL.Battlers[ "inviter" ] == pl then
				PROPKILL.Battlers[ "invitee" ]:AddKillstreak( 1 )
			else
				PROPKILL.Battlers[ "inviter" ]:AddKillstreak( 1 )
			end
		end
	end
	
		-- this is for below networking death message
	local kill_type = "smash"
	
		-- default
	local hud_message = { /*txt = prop_owner:Nick() .. " smashed " .. pl:Nick(),*/ col = Color( 255, 204, 0, 255 ) }
	
	if prop_owner != pl then
		if prop_owner:GetPos():Distance( pl:GetPos() ) >= 4000 then
			kill_type = "longshot"
			hud_message = { txt = prop_owner:Nick() .. " longshot'd " .. pl:Nick(), col = Color( 190, 30, 220, 255 ) }
			if not PROPKILL.Battling then
				prop_owner:AddLongshots( 1 )
			end
		elseif prop_owner:IsFlying() then
			kill_type = "flyby"
			hud_message = { txt = prop_owner:Nick() .. " flyby'd " .. pl:Nick(), col = Color( 20, 150, 100, 255 ) }
			if not PROPKILL.Battling then
				prop_owner:AddFlybys( 1 )
			end
		end
	end
	
	for k,v in pairs( player.GetAll() ) do
		v:ConsoleMsg( Color( 200, 100, 200, 255 ), prop_owner:Nick() .. " " .. kill_type .. "'d " .. pl:Nick() )
	end
	
	
		-- Clients can use this data for themselves
		-- e.g writing a personal kill / death tracking script
	net.Start( "props_NetworkPlayerKill" )
			-- dead player
		net.WriteEntity( pl )
			-- killer
		net.WriteEntity( prop_owner )
		net.WriteString( kill_type )
	net.Send( {pl, prop_owner} )
	
	if hud_message.txt then
		net.Start( "PK_HUDMessage" )
			net.WriteString( hud_message.txt )
			net.WriteUInt( hud_message.col.r, 8 )
			net.WriteUInt( hud_message.col.g, 8 )
			net.WriteUInt( hud_message.col.g, 8 )
		net.Broadcast()
	end
	
	net.Start( "PlayerKilled" )
		net.WriteEntity( pl )
		net.WriteString( prop_owner:GetClass() )
		net.WriteEntity( prop_owner )
	net.Broadcast()
	
	if not PROPKILL.Battling then
		pl:SetKillstreak( 0 )
	
		PROPKILL.Statistics[ "totaldeaths" ] = PROPKILL.Statistics[ "totaldeaths" ] or 0
		PROPKILL.Statistics[ "totaldeaths" ] = PROPKILL.Statistics[ "totaldeaths" ] + 1
	end
	
	if PROPKILL.Battling then
		if PROPKILL.Battlers[ "inviter" ]:GetKillstreak() >= PROPKILL.BattleAmount then
			self:EndBattle( PROPKILL.Battlers[ "inviter" ], PROPKILL.Battlers[ "invitee" ], nil, nil, PROPKILL.Battlers[ "inviter" ]:Nick(), PROPKILL.Battlers[ "inviter" ]:GetKillstreak() .. " - " .. PROPKILL.Battlers[ "invitee" ]:GetKillstreak(), PROPKILL.Battlers[ "inviter" ]:Nick() .. " has won the fight! ( " .. PROPKILL.Battlers[ "inviter" ]:GetKillstreak() .. " - " .. PROPKILL.Battlers[ "invitee" ]:GetKillstreak() .. " )" )
		elseif PROPKILL.Battlers[ "invitee" ]:GetKillstreak() >= PROPKILL.BattleAmount then
			self:EndBattle( PROPKILL.Battlers[ "invitee" ], PROPKILL.Battlers[ "inviter" ], nil, nil, PROPKILL.Battlers[ "invitee" ]:Nick(), PROPKILL.Battlers[ "inviter" ]:GetKillstreak() .. " - " .. PROPKILL.Battlers[ "invitee" ]:GetKillstreak(), PROPKILL.Battlers[ "invitee" ]:Nick() .. " has won the fight! ( " .. PROPKILL.Battlers[ "invitee" ]:GetKillstreak() .. " - " .. PROPKILL.Battlers[ "inviter" ]:GetKillstreak() .. " )" )
		end
	end
	
end

--[[function GM:PlayerDeathThink( pl )

end]]

function GM:PlayerDeathSound()
	return true
end

function GM:PlayerHurt( pl, attacker, healthRemaining, damageTaken )
		-- one hit kills yes
		-- don't do pl:Alive because DoPlayerDeath will be called twice (player is still considered alive)
	if healthRemaining > 0 and attacker:GetClass() == "prop_physics" and attacker.Owner then
		--print( "ya", pl:Nick(), healthRemaining, damageTaken )
		--pl:TakeDamage( healthRemaining, attacker, attacker )
	end
end
	
--[[

*

* Entity Handling (Spawning, Manipulation)

*

--]]
local propsMaxProps = GetConVar( "sbox_maxprops" )
function GM:PlayerSpawnProp( pl, mdl )
	if pl:Team() == TEAM_SPECTATOR or (not pl:Alive() and not PROPKILL.Config[ "dead_spawnprops" ].default) then
		pl:ChatPrint( "You must be alive to spawn props!" )
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
	if PROPKILL.BlockedModels
	and PROPKILL.BlockedModels[ string.lower( mdl ) ] then
	--or PROPKILL.BlockedModels[ string.gsub( string.lower( mdl ), "\\", "/" ) ] then
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
	
	--if pl.Props and pl.Props >= propsMaxProps:GetInt() then
	--	pl:Notify( NOTIFY_ERROR, 3, "Prop limited reached (" .. PK_MAXPROPS
	--if not pl:CheckLimit( "props" ) then
	--	return false
	--end
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
	
	--pl.PropSpawns = ( pl.PropSpawns or 0 ) + 1
	
	PROPKILL.Statistics[ "propspawns" ] = PROPKILL.Statistics[ "propspawns" ] or 0
	PROPKILL.Statistics[ "propspawns" ] = PROPKILL.Statistics[ "propspawns" ] + 1
	
			--[[Do you know there is a way you can just set draw distance on every prop? No network is needed.

		ent:SetSaveValue("fademindist", 256)
		ent:SetSaveValue("fademaxdist", 1024)

		I have used it on my sanbox server and it is perfect when some construction grabbing my fps. 
		]]
		
	ent:SetNetRequest( "Owner", pl )
	
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
	return true
end

function GM:PlayerSpawnNPC( pl )
	return pl:IsSuperAdmin()
end

function GM:PlayerSpawnEffect( pl )
	pl:Notify( NOTIFY_ERROR, 1, 4, "You're not allowed to spawn this!" )
	return false
end

PROPKILL.StoredEntities = PROPKILL.StoredEntities or {}
function GM:EntityRemoved( ent )
		-- if door then store model, pos, angle
		-- for able to respawn at a later time.
	if ent:GetClass() == "func_door"
	or ent:GetClass() == "prop_door_rotating" then
	
		print( "gm:entityremoved: doors" )
	
		PROPKILL.StoredEntities[ #PROPKILL.StoredEntities + 1 ] = { Class = ent:GetClass(), Model = ent:GetModel(), Pos = ent:GetPos(), Angles = ent:GetAngles(), }
		
	end
	
	if ent.Owner and IsValid(ent.Owner) and ent.Owner.Props and ent:GetClass() == "prop_physics" then
		ent.Owner.Props = ent.Owner.Props - 1
		if ent.Owner.Props < 0 then
			ent.Owner.Props = 0
		end
	elseif ent.Owner and IsValid(ent.Owner) and ent.Owner.Entities then
		--table.remove( ent.Owner.Entities, 
		table.RemoveByValue( ent.Owner.Entities, ent )
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

	local timeSwitch = GAMEMODE.SecondsBetweenTeamSwitches
	if pl.LastTeamSwitch and (RealTime() - pl.LastTeamSwitch) < timeSwitch then
		--pl:Notify( NOTIFY_ERROR, 4, Format( "Please wait %i more seconds before trying to change team again", ( timeSwitch - ( RealTime() - pl.LastTeamSwitch ) ) ) )
		return false, "Wait " .. math.Round( timeSwitch - ( RealTime() - pl.LastTeamSwitch ), 1 ) .. " more seconds before trying again" 
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
	for k,v in pairs( player.GetAll() ) do
		AddOriginToPVS( v:GetPos() )
	end
end
	