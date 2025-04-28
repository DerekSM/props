--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Serverside commands players can use
]]--

--[[

*

* Config setting changes

*

--]]


local function props_ChangeSetting( pl, cmd, arg )
	if not IsValid( pl ) then return end

	local setting = arg[ 1 ] or ""
	local change = arg[ 2 ]
	
	local canRun = hook.Call( "PlayerCanChangeSetting", GAMEMODE, pl, setting )
	if not canRun then 
		pl:Notify( NOTIFY_ERROR, 4, "Access denied!", true )
		return
	end
	
	if not PROPKILL.Config[ setting ] then
		pl:Notify( NOTIFY_ERROR, 4, "Incorrect setting given!", true )
		return
	end
	
	if PROPKILL.Config[ setting ].type != "button" and not change then
		pl:Notify( NOTIFY_ERROR, 4, "Incorrect second argument given!", true )
		return
	end
	
	if PROPKILL.Config[ setting ].type == "integer" then
		if not tonumber( change ) then
			pl:Notify( NOTIFY_ERROR, 4, "Setting requires an integer. Try using the menu.", true )
			return
		end
		
		if PROPKILL.Config[ setting ].max and (tonumber( change ) > PROPKILL.Config[ setting ].max) then
			pl:Notify( NOTIFY_ERROR, 4, "You can't change the setting to a number this high!" )
			return
		end
		
		local beforeChange = PROPKILL.Config[ setting ].default
		
		PROPKILL.Config[ setting ].default = tonumber( change )
		hook.Call( "OnSettingChanged", GAMEMODE, pl, setting, tostring( beforeChange ), tostring( change ) )
	elseif PROPKILL.Config[ setting ].type == "boolean" then
		change = tobool( change )
		
		local beforeChange = PROPKILL.Config[ setting ].default
		
		PROPKILL.Config[ setting ].default = change
		hook.Call( "OnSettingChanged", GAMEMODE, pl, setting, tostring( beforeChange ), tostring( change ) )
	elseif PROPKILL.Config[ setting ].type == "button" then	
		PROPKILL.Config[ setting ].func( pl )
		hook.Call( "OnSettingChanged", GAMEMODE, pl, setting )
	end
end
concommand.Add( "props_changesetting", props_ChangeSetting )

local function props_SaveSettings( pl )
	if not pl:IsSuperAdmin() then return end
	if not PROPKILL.HasSettingChangedRecently then return end

	local txt = "%s saved the gamemode's settings"

	for k,v in pairs( player.GetAll() ) do
		if v:IsAdmin() then
			v:ChatPrint( string.format( txt, pl:Nick() ) )
		else
			v:ChatPrint( string.format( txt, "SOMEONE" ) )
		end
	end
	-- Add debug in case there is rogue admin.
	print( string.format( txt, pl:Nick() ) )

	-- Found in sv_data
	props_SaveGamemodeConfig()
end
concommand.Add("props_savesettings", props_SaveSettings)

	
--[[

*

* Teams
*

--]]
local function props_JoinTeam( pl, cmd, arg )
	if not arg[ 1 ] then return end
	
	local teamid = nil
	teamid = ( team.Valid( tonumber( arg[ 1 ] ) ) and tonumber( arg[ 1 ] ) ) or PROPKILL.ValidTeams[ arg[ 1 ] ] and PROPKILL.ValidTeams[ arg[ 1 ] ]

	if not teamid then return end
	
	local canSwitchTeams, reason = hook.Call( "PlayerCanJoinTeam", GAMEMODE, pl, teamid )
	
	if not canSwitchTeams then
		pl:Notify( NOTIFY_ERROR, 4, reason or ".." )
		return
	end
	
	for k,v in player.Iterator() do
		PROPKILL.ChatText( v, team.GetColor( pl:Team() ), pl:Nick(), color_white, " joined team ", team.GetColor( teamid ), team.GetName( teamid ) )
	end
	
	pl:SetTeam( teamid )
	pl:Spawn()

	if pl:Team() == TEAM_SPECTATOR then
		pl:SetKillstreak( 0 )
	end
end
concommand.Add( "props_changeteam", props_JoinTeam )
	
--[[

*

* Battling
*

--]]
local function props_SendFightInvite( pl, cmd, args )
	if not IsValid( pl ) or not args[ 1 ] or not FindPlayer( args[ 1 ] ) then return end
	
	if PROPKILL.Battling then
		pl:Notify( NOTIFY_ERROR, 4, "Someone is already battling!" )
		return
	end
	
	if PROPKILL.BattleCooldown > CurTime() then
		pl:Notify( NOTIFY_ERROR, 4, "A battle was recently fought. Wait " .. math.Round( PROPKILL.BattleCooldown - CurTime() ) .. " seconds" )
		return
	end
	
	--if pl.BattleCooldown and pl.BattleCooldown > CurTime() then
	if PROPKILL.PlayerBattleCooldowns[ pl:SteamID64() ] and PROPKILL.PlayerBattleCooldowns[ pl:SteamID64() ] > CurTime() then
		pl:Notify( NOTIFY_ERROR, 4, "You recently sent a battle request. Wait " .. math.Round( PROPKILL.PlayerBattleCooldowns[ pl:SteamID64() ]  - CurTime() ) .. " seconds" )
		return
	end
	
	local target = FindPlayer( args[ 1 ] )
	
	local canBattle, reason = hook.Call( "PlayerCanBattle", GAMEMODE, pl, target )
	if not canBattle then
		pl:Notify( NOTIFY_ERROR, 4, reason or "..." )
		return
	end
	
	local killamt = args[ 2 ] and tonumber( args[ 2 ] ) or PROPKILL.Config[ "battle_defaultkills" ].default
	
	if killamt < PROPKILL.Config[ "battle_minkills" ].default or killamt > PROPKILL.Config[ "battle_maxkills" ].default then
		pl:Notify( NOTIFY_ERROR, 4, "Kills must be between " .. PROPKILL.Config[ "battle_minkills" ].default .. " and " .. PROPKILL.Config[ "battle_maxkills" ].default )
		return
	end
	
	local propamt = args[ 3 ] and tonumber( args[ 3 ] ) or PROPKILL.Config[ "battle_defaultprops" ].default
	
	if propamt < PROPKILL.Config[ "battle_minprops" ].default or propamt > PROPKILL.Config[ "battle_maxprops" ].default then
		pl:Notify( NOTIFY_ERROR, 4, "Prop limit must be between " .. PROPKILL.Config[ "battle_minprops" ].default .. " and " .. PROPKILL.Config[ "battle_maxprops" ].default )
		return
	end
	
	local funfight = args[ 4 ] and tobool( args[ 4 ] ) or false
	local playerdormant = args[ 5 ] and tobool( args[ 5 ] ) or false
	local propsdormant = args[ 6 ] and tobool( args[ 6 ] ) or false

	PROPKILL.PlayerBattleCooldowns[ pl:SteamID64() ] = CurTime() + PROPKILL.Config[ "battle_invitecooldown" ].default
	--pl.BattleCooldown = CurTime() + PROPKILL.Config[ "battle_invitecooldown" ].default
	
		-- used to make sure a player can't fake a fight
	target.BattleInvites = target.BattleInvites or {}
	target.BattleInvites[ pl ] = { kills = killamt, props = propamt, funfight = funfight, playerdormant = playerdormant, propsdormant = propsdormant }
	
	pl:SendBattleInvite( target, killamt, propamt, funfight, playerdormant, propsdormant )
end
concommand.Add( "props_requestbattle", props_SendFightInvite )

function props_AcceptBattle( pl, cmd, args )
	if not IsValid( pl ) or not args[ 1 ] or not tonumber( args[ 1 ] )
	or not IsValid( Player( args[ 1 ] ) ) or not pl.BattleInvites
	or not pl.BattleInvites[ Player( args[ 1 ] ) ] then return end
	
	if PROPKILL.Battling then 
		pl:Notify( 1, 4, "There is already a battle in progress!" )
		return 
	end
	
	GAMEMODE:StartBattle( Player( args[ 1 ] ), pl, pl.BattleInvites[ Player( args[ 1 ] ) ].kills, pl.BattleInvites[ Player( args[ 1 ] ) ].props, pl.BattleInvites[ Player( args[ 1 ] ) ].funfight, pl.BattleInvites[ Player( args[ 1 ] ) ].playerdormant, pl.BattleInvites[ Player( args[ 1 ] ) ].propsdormant  )
end
concommand.Add( "props_acceptbattle", props_AcceptBattle )

function props_DeclineBattle( pl, cmd, args )
	if not IsValid( pl ) or not args[ 1 ] or not tonumber( args[ 1 ] )
	or not IsValid( Player( args[ 1 ] ) ) or not pl.BattleInvites or not
	pl.BattleInvites[ Player( args[ 1 ] ) ] then return end
	
	Player( args[ 1 ] ):Notify( 0, 4, pl:Nick() .. " has declined the fight!" )
	pl.BattleInvites[ Player( args[ 1 ] ) ] = nil
	pl:Notify( 0, 4, "You declined to fight " .. Player( args[ 1 ] ):Nick() .. "!" )
end
concommand.Add( "props_declinebattle", props_DeclineBattle )

local function props_PauseBattle( pl, cmd, args )
	if not IsValid( pl ) then return end
	if not PROPKILL.Battling then return end
	if PROPKILL.BattlePaused then
		pl:Notify( 1, 4, "The battle is already paused!" )
		return
	end
	if PROPKILL.Battlers[ "inviter" ] != pl and PROPKILL.Battlers[ "invitee" ] != pl then
		pl:Notify( 1, 4, "You aren't currently in a fight! " )
		return
	end
	if PROPKILL.Config[ "battle_maxpauses" ].default == 0 or pl.BattlePauses and pl.BattlePauses >= PROPKILL.Config[ "battle_maxpauses" ].default then
		pl:Notify( 1, 4, "You have already reached your maximum pauses this fight!", true )
		return
	end
	
	pl.BattlePauses = (pl.BattlePauses or 0) + 1
	if math.random( 1, 7 ) == 3 then
		BroadcastLua( [[RunConsoleCommand( "play", "vo/npc/male01/question29.wav" )]] )
	elseif math.random( 1, 5 ) == 4 then
		BroadcastLua( [[RunConsoleCommand( "play", "vo/npc/male01/question25.wav" )]] )
	elseif math.random( 1, 8 ) == 2 then
		BroadcastLua( [[RunConsoleCommand( "play", "vo/npc/male01/question25.wav" )]] )
	end
	GAMEMODE:PauseBattle( pl )
end
concommand.Add( "props_pausebattle", props_PauseBattle )

--[[

*

* Misc
*

--]]
local function props_ResetMyStats( pl, cmd, args )
	if not IsValid( pl ) then return end
	if pl:GetTotalFrags() < 100 then
		pl:Notify( 1, 4, "Reach 100 kills before resetting your stats." )
		return
	end
	
	pl:SetTotalFrags( 0 )
	pl:SetTotalDeaths( 0 )
	pl:SetFlyby( 0 )
	pl:SetLongshot( 0 )
	pl:SetHeadsmash( 0 )
	pl:SetBestKillstreak( 0 )
	pl:SetBestDeathstreak( 0 )
	
	pl:SavePropkillData()
	hook.Run("props_PlayerResetStats", pl)
end
concommand.Add( "props_resetmystats", props_ResetMyStats )


	-- requested
concommand.Add( "undoall", function( pl )
	pl:ConCommand( "gmod_cleanup props" )
end )


	-- Running props_achievements by itself will announce ALL achievements you've accomplished
	-- Running props_achievements by it's fancy title will tell everyone WHEN you accomplished
local function props_AnnounceMyAchievements( pl, cmd, args )
	if not IsValid( pl ) then return end
	if pl.LastAnnounced and pl.LastAnnounced > CurTime() then
		pl:PrintMessage(HUD_PRINTCONSOLE, "Wait a few seconds before running again.")
		return
	end

		-- We want specifics.
	if args[1] and args[1] != " " then
		-- check if its a valid fancy title, if not then let the player know.
		local FullArg = table.concat(args, " ")
		local Achievement = nil
		for k,v in next, PROPKILL.GetCombatAchievements() do
			if string.lower(v:GetFancyTitle()) == string.lower(FullArg) then
				Achievement = v
				break
			end
		end

		if not Achievement then
			pl:PrintMessage(HUD_PRINTCONSOLE, "props_achievements <Title>\n\tEg: props_achievements Killing spree")
			return
		end

		if Achievement:GetProgression(pl) then
			local AchievementData = pl.AchievementData[ Achievement:GetUniqueID() ]
			for k,v in next, player.GetHumans() do
				if AchievementData.UnlockedTime then
					PROPKILL.ChatText( v, PROPKILL.Colors.Blue,
						"Props: ", team.GetColor(pl:Team()), pl:Nick(),
						color_white, " completed the \"" .. Achievement:GetFancyTitle() .. "\" achievement on " .. os.date("%d %b %Y", AchievementData.UnlockedTime)
					)
				else
					PROPKILL.ChatText( v, PROPKILL.Colors.Blue,
						"Props: ", team.GetColor(pl:Team()), pl:Nick(),
						color_white, " completed the \"" .. Achievement:GetFancyTitle() .. "\" achievement before today"
					)
				end
			end
		end

	else
		local CountAchievements = 0
		for k,v in next, pl.AchievementData or {} do
			if v.Unlocked then
				CountAchievements = CountAchievements + 1
			end
		end

		for k,v in next, player.GetHumans() do
			PROPKILL.ChatText( v, PROPKILL.Colors.Blue,
				"Props: ", team.GetColor(pl:Team()), pl:Nick(), color_white, " has completed " .. CountAchievements .. "/" .. PROPKILL.CombatAchievementsCount .. " achievements" )
		end
	end

	pl.LastAnnounced = CurTime() + 15
end
concommand.Add( "props_achievements", props_AnnounceMyAchievements )
