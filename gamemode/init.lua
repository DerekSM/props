--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Initializes gamemode..
]]--

-- Switch from having to network all this shit pointlessly to NWVars ??

	-- add !aliases command -- view stored player names over time

PROPKILL = PROPKILL or {}
PROPKILL.TopPropsSession = PROPKILL.TopPropsSession or {}
PROPKILL.TopPropsCache = PROPKILL.TopPropsCache or {}
PROPKILL.TopPropsTotal = PROPKILL.TopPropsTotal or {}
PROPKILL.TopPropsTotalCache = PROPKILL.TopPropsTotalCache or {}
PROPKILL.TopPlayers = PROPKILL.TopPlayers or {}
PROPKILL.TopPlayersCache = PROPKILL.TopPlayersCache or {}
PROPKILL.RecentBattles = PROPKILL.RecentBattles or {}

PROPKILL.Statistics = PROPKILL.Statistics or {}

PROPKILL.HugeProps = PROPKILL.HugeProps or {}

PROPKILL.Battling = PROPKILL.Battling or false
PROPKILL.BattleAmount = PROPKILL.BattleAmount or 0
PROPKILL.Battlers = PROPKILL.Battlers or {}
PROPKILL.BattleInvited = PROPKILL.BattleInvited or {}
PROPKILL.BattleCooldown = 0--PROPKILL.BattleCooldown or 0
PROPKILL.BattlePaused = PROPKILL.BattlePaused or false
PROPKILL.BattleFun = PROPKILL.BattleFun or false

PROPKILL.PlayerBattleCooldowns = PROPKILL.PlayerBattleCooldowns or {}
	-- steamid64: seconds

DEFINE_BASECLASS( "gamemode_sandbox" )

util.AddNetworkString( "PK_HUDMessage" )
util.AddNetworkString( "PK_UpdateConfig" )
util.AddNetworkString( "PK_BattleEnd" )
util.AddNetworkString( "PK_UpdateKillstreak" )
util.AddNetworkString( "props_NetworkPlayerKill" )
util.AddNetworkString( "props_NetworkPlayerTotals" )
util.AddNetworkString( "props_UpdateConfig" )
util.AddNetworkString( "props_UpdateTopPropsSession" )
util.AddNetworkString( "props_UpdateTopPropsTotal" )
util.AddNetworkString( "props_FightInvite" )
util.AddNetworkString( "props_ShowClicker" )
util.AddNetworkString( "props_BattleInit" )
util.AddNetworkString( "props_EndBattle" )
util.AddNetworkString( "props_UpdateFullConfig" )
util.AddNetworkString( "props_SendRecentBattles" )
util.AddNetworkString( "props_StopResumeBattle" )
util.AddNetworkString( "props_FightResults" )
util.AddNetworkString( "props_PlaySoundURL" )
util.AddNetworkString( "props_AnnounceNewKillstreak" )
--util.AddNetworkString( "props_RequestGamemodeConfigSync" )
--util.AddNetworkString( "props_SendGamemodeConfigSync" )
util.AddNetworkString( "props_NetworkPlayerAchievement" )
util.AddNetworkString( "props_NetworkPlayerAllAchievementPercentages" )
util.AddNetworkString( "props_NetworkPlayerAchievementPercentages" )
util.AddNetworkString( "props_NetworkPlayerAchievementsCompleted" )
util.AddNetworkString( "props_UpdatePlayerAchievementProgress" )
util.AddNetworkString( "props_SendPlayerAllPlayerAchievementsProgress" )


AddCSLuaFile( "sh_init.lua" )
include( "sh_init.lua" )

AddCSLuaFile( "sh_config.lua" )
include( "sh_config.lua" )

AddCSLuaFile( "cl_init.lua" )

AddCSLuaFile( "cl_hooks_base.lua" )
AddCSLuaFile( "cl_hooks.lua" )

include( "sv_util.lua" )
AddCSLuaFile( "sh_util.lua" )
include( "sh_util.lua" )
AddCSLuaFile( "cl_util.lua" )
include( "sv_player.lua" )

AddCSLuaFile( "sh_player.lua" )
include( "sh_player.lua" )

include( "pon.lua" )
include( "sv_util.lua" )
include( "sv_data.lua" )
include( "sv_hooks_base.lua" )
include( "sv_hooks.lua" )

AddCSLuaFile( "sh_hooks.lua" )
include( "sh_hooks.lua" )

AddCSLuaFile( "sh_blockedmodels.lua" )
include( "sh_blockedmodels.lua" )

include( "sv_commands.lua" )

AddCSLuaFile( "sh_speedy.lua")
include( "sh_speedy.lua" )

include( "sh_achievements.lua" )
include( "sv_achievements.lua" )

AddCSLuaFile( "sh_achievements.lua" )
AddCSLuaFile( "cl_achievements.lua" )

AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "vgui/scoreboard/props_scoreboard.lua" )
AddCSLuaFile( "vgui/scoreboard/props_playerrow.lua" )
AddCSLuaFile( "vgui/scoreboard/props_scoreboard_alt.lua")
AddCSLuaFile( "vgui/scoreboard/props_playerrow_alt.lua" )

AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "vgui/hud/horizontalbar.lua" )
AddCSLuaFile( "vgui/skins/props.lua" )
AddCSLuaFile( "vgui/skins/props_test.lua" )

AddCSLuaFile( "cl_commands.lua" )
AddCSLuaFile( "cl_menus.lua" )
AddCSLuaFile( "vgui/menus/dswitch.lua" )
AddCSLuaFile( "vgui/menus/props_main.lua" )
AddCSLuaFile( "vgui/menus/props_teams.lua" )
AddCSLuaFile( "vgui/menus/props_newbattle.lua" )
AddCSLuaFile( "vgui/menus/props_config.lua" )
AddCSLuaFile( "vgui/menus/props_battleinvite.lua" )
AddCSLuaFile( "vgui/menus/props_stats.lua" )
AddCSLuaFile( "vgui/menus/props_battleresults.lua" )
AddCSLuaFile( "vgui/menus/props_topprops_new.lua" )
AddCSLuaFile( "vgui/menus/props_clientconfig.lua" )
AddCSLuaFile( "vgui/menus/props_achievements.lua" )
AddCSLuaFile( "vgui/menus/props_confignocolors.lua" )
AddCSLuaFile( "vgui/menus/props_botsmenu.lua" )

local pkfiles, pkfolders = file.Find( "gamemodes/" .. GM.FolderName .. "/gamemode/modules/*.lua", "GAME" )

for k,v in next, pkfiles do
	if string.find( v, "sv_" ) then
		print( GM.Name .. "; Found server module: " .. v )
		include( "modules/" .. v )
	elseif string.find(v, "cl_") then
		print( GM.Name .. "; Found client module: " .. v )
		AddCSLuaFile( "modules/" .. v )
	else
		print( GM.Name .."; Found shared module: " .. v )
		include( "modules/" .. v )
		AddCSLuaFile( "modules/" .. v )
	end
end
