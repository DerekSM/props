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
		hook.Call( "OnSettingChanged", nil, pl, setting, tostring( beforeChange ), tostring( change ) )
	elseif PROPKILL.Config[ setting ].type == "boolean" then
		change = tobool( change )
		
		local beforeChange = PROPKILL.Config[ setting ].default
		
		PROPKILL.Config[ setting ].default = change
		hook.Call( "OnSettingChanged", nil, pl, setting, tostring( beforeChange ), tostring( change ) )
	elseif PROPKILL.Config[ setting ].type == "button" then	
		PROPKILL.Config[ setting ].func( pl )
		hook.Call( "OnSettingChanged", nil, pl, setting )
	end
end
concommand.Add( "props_changesetting", props_ChangeSetting )
	
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
	
	local canSwitchTeams, reason = hook.Call( "PlayerCanJoinTeam", nil, pl, teamid )
	
	if not canSwitchTeams then
		pl:Notify( NOTIFY_ERROR, 4, reason or ".." )
		return
	end
	
	for k,v in pairs( player.GetAll() ) do
		PROPKILL.ChatText( v, team.GetColor( pl:Team() ), pl:Nick(), color_white, " joined team ", team.GetColor( teamid ), team.GetName( teamid ) )
	end
	
	pl:SetTeam( teamid )
	pl:Spawn()
end
concommand.Add( "props_changeteam", props_JoinTeam )

concommand.Add( "props_bigandstrong", function( pl )
	BroadcastLua( [[sound.PlayURL( "http://tts.peniscorp.com/speak.lua?Milk helps support healthy bone growth to help YOU grow up big and strong!", "", function() end )]] )
end)
	
	
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
	
	if pl.BattleCooldown and pl.BattleCooldown > CurTime() then
		pl:Notify( NOTIFY_ERROR, 4, "You recently sent a battle request. Wait " .. math.Round( pl.BattleCooldown - CurTime() ) .. " seconds" )
		return
	end
	
	local target = FindPlayer( args[ 1 ] )
	
	local canBattle, reason = hook.Call( "PlayerCanBattle", nil, pl, target )
	if not canBattle then
		pl:Notify( NOTIFY_ERROR, 4, reason or "..." )
		return
	end
	
	local amt = args[ 2 ] or PROPKILL.Config[ "battle_defaultkills" ].default
	
	pl.BattleCooldown = CurTime() + PROPKILL.Config[ "battle_invitecooldown" ].default
	
	--target.BattleInvites = target.BattleInvites or {}
	--target.BattleInvites[ #target.BattleInvites + 1 ] = pl
	
	pl:SendBattleInvite( target, amt )
end