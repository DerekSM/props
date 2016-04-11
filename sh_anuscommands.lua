--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Adds propkilling commands to ANUS
]]--

if not anus then return end

local plugin = {}
plugin.id = "pkcleanup"
plugin.name = "Cleanup"
plugin.author = "Shinycow"
plugin.help = "Clean up the map."
plugin.example = ""
plugin.chatcommand = "pkcleanup"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg )
	util.CleanUpMap( true )
	
	anus.NotifyPlugin( pl, plugin.id, "cleaned up the map!" )
end

anus.RegisterPlugin( plugin )


local plugin = {}
plugin.id = "stopfight"
plugin.name = "Stop Fight"
plugin.author = "Shinycow"
plugin.help = "Stops the current fight"
plugin.example = ""
plugin.chatcommand = "stopfight"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg )
	if not PROPKILL.Battling then return end
	
	GAMEMODE:EndBattle( PROPKILL.Battlers[ "inviter" ], PROPKILL.Battlers[ "invitee" ], nil, true )
	
	anus.NotifyPlugin( pl, plugin.id, "has stopped the fight!" )
end

anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "forfeit"
plugin.name = "Forfeit"
plugin.author = "Shinycow"
plugin.help = "Forfeits the current fight"
plugin.example = ""
plugin.chatcommand = "forfeit"
plugin.defaultAccess = "user"

function plugin:OnRun( pl, arg )
	if not PROPKILL.Battling then return end
	if PROPKILL.Battlers[ "inviter" ] != calling_ply and PROPKILL.Battlers[ "invitee" ] != calling_ply then return end
	
	if calling_ply == PROPKILL.Battlers[ "inviter" ] then
		GAMEMODE:EndBattle( PROPKILL.Battlers[ "inviter" ], PROPKILL.Battlers[ "invitee" ], calling_ply:Nick(), false, PROPKILL.Battlers[ "invitee" ]:Nick() )
	else
		GAMEMODE:EndBattle( PROPKILL.Battlers[ "inviter" ], PROPKILL.Battlers[ "invitee" ], PROPKILL.Battlers[ "invitee" ]:Nick(), false, PROPKILL.Battlers[ "inviter" ]:Nick() )
	end
	
	anus.NotifyPlugin( pl, plugin.id, "has forfeited the fight!" )
end

anus.RegisterPlugin( plugin )

if SERVER then
	util.AddNetworkString( "props_GrabIP" )
else
	net.Receive( "props_GrabIP", function()
		local ip = net.ReadString()
		
		SetClipboardText( ip )
	end )
end

local plugin = {}
plugin.id = "grabip"
plugin.name = "Grab IP"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>"
plugin.help = "Gets the IP of your target(s)"
plugin.example = "anus grabip bot"
plugin.chatcommand = "grabip"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, target )
	if type( target ) == "table" then
		pl:PrintMessage( HUD_PRINTCONSOLE, "\n\n    PLAYER IPS HERE:::" )
		
		for k,v in next, target do
			pl:PrintMessage( HUD_PRINTCONSOLE, v:Nick() .. " - " .. v:IPAddress() )
		end
		
		pl:ChatPrint( "You grabbed the IP from more than one person.\nThe IPs have been printed to your console." )
	else
		net.Start( "props_GrabIP" )
			net.WriteString( target:IPAddress() )
		net.Send( pl )
		pl:Notify( NOTIFY_GENERIC, 6, target:Nick() .. "'s IP has been copied to your clipboard", true )
	end
	
	--anus.NotifyPlugin( pl, plugin.id, "copied the IP of ", anus.StartPlayerList, target, anus.EndPlayerList )
end

anus.RegisterPlugin( plugin )

local teamList = { "spectator", "deathmatch", "red", "blue" }

local plugin = {}
plugin.id = "setteam"
plugin.name = "Set team"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <string:Team>"
plugin.help = "Sets the target(s) to a certain team"
plugin.example = ""
plugin.chatcommand = "setteam"
plugin.defaultAccess = "admin"

function plugin:OnRun( pl, arg, target )
	local team = arg[ 1 ]
	if not PROPKILL.ValidTeams[ arg[ 1 ] ] then
		team = "spectator"
	end
	
	local oldteam = team
	team = PROPKILL.ValidTeams[ team ]
	
	if type( target ) == "table" then
		for k,v in next, target do
			v:SetTeam( team )
			v:Spawn()
		end
		
		anus.NotifyPlugin( pl, plugin.id, "set the team of ", anus.StartPlayerList, target, anus.EndPlayerList, " to ", COLOR_STRINGARGS, team )
	else
		target:SetTeam( team )
		target:Spawn()

		anus.NotifyPlugin( pl, plugin.id, "set the team of ", target, " to ", COLOR_STRINGARGS, team )
	end
end

anus.RegisterPlugin( plugin )

local plugin = {}
plugin.id = "toolgun"
plugin.name = "Toolgun"
plugin.author = "Shinycow"
plugin.help = "Gives yourself the tool gun"
plugin.example = ""
plugin.chatcommand = "toolgun"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, target )
	pl:Give( "gmod_tool" )
		
	anus.NotifyPlugin( pl, plugin.id, "gave themself the tool gun." )
end

anus.RegisterPlugin( plugin )


local plugin = {}
plugin.id = "setkills"
plugin.name = "Set Kills"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <number:Amount>"
plugin.help = "Changes the total kills of the target(s)"
plugin.example = ""
plugin.chatcommand = "setkills"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, target )
	local amount = tonumber( arg[ 1 ] )
	if type( target ) == "table" then
		for k,v in next, target do
			v:SetTotalFrags( amount, true )
		end
		
		anus.NotifyPlugin( pl, plugin.id, "set the total kills of ", anus.StartPlayerList, target, anus.EndPlayerList, " to ", COLOR_STRINGARGS, amount	)
	else
		target:SetTotalFrags( amount, true )
		
		anus.NotifyPlugin( pl, plugin.id, "set the total kills of ", target, " to ", COLOR_STRINGARGS, amount )
	end
end

anus.RegisterPlugin( plugin )


local plugin = {}
plugin.id = "setdeaths"
plugin.name = "Set Deaths"
plugin.author = "Shinycow"
plugin.usage = "<player:Player>; <number:Amount>"
plugin.help = "Changes the total deaths of the target(s)"
plugin.example = ""
plugin.chatcommand = "setdeaths"
plugin.defaultAccess = "superadmin"

function plugin:OnRun( pl, arg, target )
	local amount = tonumber( arg[ 1 ] )
	if type( target ) == "table" then
		for k,v in next, target do
			v:SetTotalDeaths( amount )
		end
		
		anus.NotifyPlugin( pl, plugin.id, "set the total deaths of ", anus.StartPlayerList, target, anus.EndPlayerList, " to ", COLOR_STRINGARGS, amount	)
	else
		target:SetTotalDeaths( amount )
		
		anus.NotifyPlugin( pl, plugin.id, "set the total deaths of ", target, " to ", COLOR_STRINGARGS, amount )
	end
end

anus.RegisterPlugin( plugin )


local plugin = {}
plugin.id = "pause"
plugin.name = "Pause Battle"
plugin.author = "Shinycow"
plugin.help = "Pauses the current battle"
plugin.example = ""
plugin.chatcommand = "pause"
plugin.defaultAccess = "user"

function plugin:OnRun( pl, arg, target )
	if not PROPKILL.Battling or PROPKILL.BattlePaused then return end
	if PROPKILL.Battlers[ "inviter" ] != pl and PROPKILL.Battlers[ "invitee" ] != pl then return end
	pl:ConCommand( "props_pausebattle" )
	
	anus.NotifyPlugin( pl, plugin.id, "paused the battle" )
end

anus.RegisterPlugin( plugin )


local plugin = {}
plugin.id = "resetmystats"
plugin.name = "ResetMyStats"
plugin.author = "Shinycow"
plugin.help = "Resets your stats (total kills,deaths,streaks,bonuses)"
plugin.example = ""
plugin.chatcommand = "resetmystats"
plugin.defaultAccess = "user"

function plugin:OnRun( pl, arg, target )
	local notify = pl:TotalFrags() >= 100
	pl:ConCommand( "props_resetmystats" )
	
	if notify then
		anus.NotifyPlugin( pl, plugin.id, "reset their stats" )
	end
end

anus.RegisterPlugin( plugin )