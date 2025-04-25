--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Scoreboard initialization 
]]--

surface.CreateFont( "ScoreboardDefault",
{
	font		= "Helvetica",
	size		= 22,
	weight		= 800
})

surface.CreateFont( "ScoreboardDefaultTitle",
{
	font		= "Helvetica",
	size		= 32,
	weight		= 800
})

surface.CreateFont( "ScoreboardSmall", 
{
	font = "Helvetica",
	size = 18,
	weight = 800,
} )

surface.CreateFont("ScoreboardLarge", 
{
	size = 36,
	weight = 800,
	antialias = true,
	shadow = true,
	font = "Helvetica"
})

--[[TeamsScoreboard =
{
TEAM_SPECTATOR,
TEAM_DEATHMATCH,
TEAM_RED,
TEAM_BLUE,
}]]

	-- Arrow through, first shows spec / deathmatch,
	-- second shows red / blue
TeamsScoreboard =
{
	[ 1 ] =
		{
		TEAM_SPECTATOR,
		TEAM_DEATHMATCH,
		},
	
	[ 2 ] =
		{
		TEAM_RED,
		TEAM_BLUE,
		},
}

	-- lua_run_cl local f = FindMetaTable("Player").Deaths print( f( LocalPlayer() ) )
	
InfoScoreboard =
{
	{
		-- Nice name for it, How to access it
	id = { "%team", FindMetaTable( "Player" ).Name },
		-- Space needed to hold this info / 1
	space = 0.3,
	},
	
	{
	id = { "Total Kills", FindMetaTable( "Player" ).GetTotalFrags },
	space = 0.19,
	},
	
	{
	id = { "Total Deaths", FindMetaTable( "Player" ).GetTotalDeaths },
	space = 0.19,
	},
	
	{
	id = { "Kills", FindMetaTable( "Player" ).Frags },
	space = 0.13,
	},
	
	{
	id = { "Deaths", FindMetaTable( "Player" ).Deaths },
	space = 0.13,
	},
	
	{
	id = { "Ping", FindMetaTable( "Player" ).Ping },
	space = 0.13,
	},
}

include( "vgui/scoreboard/props_scoreboard.lua" )
include( "vgui/scoreboard/props_playerrow.lua" )
include( "vgui/scoreboard/props_scoreboard_alt.lua" )
include( "vgui/scoreboard/props_playerrow_alt.lua" )

AddClientConfigItem( "props_NewScoreboard",
	{
	Name = "Show Alternate Scoreboard",
	default = false,
	type = "boolean",
	desc = "Show the new, singular scoreboard",
	}
)

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardShow( )
   Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()

	if g_Scoreboard then
		g_Scoreboard:Remove()
		g_Scoreboard = nil
	end

	--if UseNewScoreboard:GetInt() > 0 then
	if PROPKILL.ClientConfig["props_NewScoreboard"].currentvalue then
		g_Scoreboard = vgui.Create( "props_scoreboard_alt" )
	else
		g_Scoreboard = vgui.Create( "props_scoreboard" )
	end

	--[[if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled( false )
	end]]

end

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardHide( )
   Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()

	--[[if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Hide()
	end]]
	
	if g_Scoreboard then
		g_Scoreboard:Remove()
	end

end


--[[---------------------------------------------------------
   Name: gamemode:HUDDrawScoreBoard( )
   Desc: If you prefer to draw your scoreboard the stupid way (without vgui)
-----------------------------------------------------------]]
function GM:HUDDrawScoreBoard()

end
