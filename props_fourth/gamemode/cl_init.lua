--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Initializes gamemode for all clientside things.
]]--

PROPKILL = PROPKILL or {}
PROPKILL.TopProps = PROPKILL.TopProps or {}
PROPKILL.TopPlayers = PROPKILL.TopPlayers or {}

local function LoadModules()
	local root = ((GM and GM.FolderName) or (GAMEMODE and GAMEMODE.FolderName) or "props") .. "/gamemode/modules/"
	local pkfiles, pkfolders = file.Find( root .. "*", "LUA" )
	
	for k,v in next, pkfiles do
	
		if not string.find( v, "sv_" ) then
			print( GM.Name or "Props" .. "; Found client module: " .. v )
			include( root .. v )
		end
		
	end
end

--include( "player_class/player_propkill.lua" )

include( "sh_init.lua" )
include( "sh_config.lua" )
include( "sh_util.lua" )
include( "sh_player.lua" )
include( "sh_kd.lua" )
include( "cl_hooks_base.lua" )
include( "cl_hooks.lua" )
include( "cl_hud.lua" )
include( "sh_hooks.lua" )

include( "sh_blockedmodels.lua" )

include( "cl_scoreboard.lua" )
include( "vgui/scoreboard/props_playerrow.lua" )
include( "vgui/scoreboard/props_scoreboard.lua" )

include( "cl_hud.lua" )
include( "vgui/hud/horizontalbar.lua" )

include( "cl_menus.lua" )
include( "vgui/menus/props_main.lua" )
include( "vgui/menus/props_battleinvite.lua" )

LoadModules()

local function CreateHUD()
	if not _G.LocalPlayer or not IsValid( LocalPlayer() ) then
		timer.Simple( 0.5, function()
			CreateHUD() 
		end )
		return
	end
	
end

--[[net.Receive( "props_NetworkPlayerTotals", function()
	local ent = net.ReadEntity()
	local accuracy = net.ReadFloat()
	local frags = net.ReadUInt( 20 )
	local deaths = net.ReadUInt( 20 )
	
	if not ent.SetTotalFrags then
		return
	end
	ent:SetAccuracy( accuracy )
	ent:SetTotalFrags( frags )
	ent:SetTotalDeaths( deaths )
end )]]

	-- those without falco's small scripts
concommand.Add( "falco_180", function()
	local a = LocalPlayer():EyeAngles()
	LocalPlayer():SetEyeAngles( Angle( a.p, a.y - 180, a.r ) )
end )

concommand.Add( "falco_180up", function()
	local a = LocalPlayer():EyeAngles()
	LocalPlayer():SetEyeAngles( Angle( a.p - a.p - a.p, a.y - 180, a.r ) )
	RunConsoleCommand( "+jump" )
	timer.Simple( 0.2, function() RunConsoleCommand("-jump") end )
end )