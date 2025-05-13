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
PROPKILL.TopPropsSession = PROPKILL.TopPropsSession or {}
PROPKILL.TopPropsTotal = PROPKILL.TopPropsTotal or {}
PROPKILL.TopPlayers = PROPKILL.TopPlayers or {}

PROPKILL.Battling = PROPKILL.Battling or false
PROPKILL.BattleAmount = PROPKILL.BattleAmount or 3
PROPKILL.Battlers = PROPKILL.Battlers or {}
PROPKILL.BattlePaused = PROPKILL.BattlePaused or false
PROPKILL.Statistics = PROPKILL.Statistics or {}

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

PROPKILL.ClientConfig = PROPKILL.ClientConfig or {}
function AddClientConfigItem( id, tbl )
	if not id then return end
	if not tbl then return end
	if not tbl.type then return end
	if PROPKILL.Config[ id ] then
		print( "PROPKILL CONFIG ID '" .. id .. "' ALREADY EXISTS!" )
		return
	end

	tbl.desc = tbl.desc or "No information available."
	tbl.currentvalue = cookie.GetString( id, tbl.default )
	if tbl.type == "integer" then
		tbl.currentvalue = tonumber(tbl.currentvalue)
	elseif tbl.type == "boolean" then
		tbl.currentvalue = tobool(tbl.currentvalue)
	end

	tbl.Category = tbl.Category or "Unknown"

	PROPKILL.ClientConfig[ id ] = tbl
end

function ChangeClientConfigValue( id, value )
	PROPKILL.ClientConfig[ id ].currentvalue = value
	cookie.Set( id, tostring(value) )
	hook.Run("Props_ClientConfigChanged", id, value)
end


include( "sh_init.lua" )
include( "sh_config.lua" )
include( "sh_util.lua" )
include( "cl_util.lua" )
include( "sh_player.lua" )
include( "cl_hooks_base.lua" )
include( "cl_hooks.lua" )
include( "cl_hud.lua" )
include( "sh_hooks.lua" )

include( "sh_blockedmodels.lua" )

include( "sh_speedy.lua" )

include( "cl_scoreboard.lua" )
include( "sh_achievements.lua" )
include( "cl_achievements.lua" )

include( "cl_hud.lua" )
include( "vgui/hud/horizontalbar.lua" )
include( "vgui/skins/props.lua")
include( "vgui/skins/props_test.lua")

include( "cl_commands.lua" )
include( "cl_menus.lua" )
include( "vgui/menus/dswitch.lua" )
include( "vgui/menus/props_main.lua" )
include( "vgui/menus/props_battleinvite.lua" )
include( "vgui/menus/props_battleresults.lua" )


LoadModules()
