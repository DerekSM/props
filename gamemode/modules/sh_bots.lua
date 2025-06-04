AddConfigItem( "bots_enable",
	{
	Name = "Enable bots",
	Category = "Bots",
	default = true,
	type = "boolean",
	desc = "Turn on bot pathing to allow propsurfing around the map",
	tags = {"toggle"}
	}
)

	-- doesn't do anything.
AddConfigItem( "bots_kill",
	{
	Name = "Enable bot killing",
	Category = "Bots",
	default = true,
	type = "boolean",
	desc = "Allow bots to kill other players",
	tags = {"toggle"}
	}
)

AddConfigItem( "bots_maxplayers",
	{
	Name = "Max Players + bots",
	Category = "Bots",
	default = 2,
	type = "integer",
	desc = "How many players are allowed to be on with a bot",
	}
)

AddConfigItem( "bots_killbots",
	{
	Name = "Enable bots targeting bots",
	Category = "Bots",
	default = false,
	type = "boolean",
	desc = "Allow bots to target and kill other bots",
	}
)

-- Version 2 of sv_bots-specific config items
AddConfigItem( "bots_legacybots",
	{
	Name = "Use Legacy Bot Path System",
	Category = "Bots",
	default = false,
	type = "boolean",
	desc = "Backwards compatibility with old bot paths",
	tags = {"toggle"}
	}
)

AddConfigItem( "bots_adminonly",
	{
	Name = "Admin-only bot paths",
	Category = "Bots",
	default = true,
	type = "boolean",
	desc = "Only admins can create and delete bot paths",
	tags = {"toggle"}
	}
)

	-- This will take into account the bots_adminonly config
AddConfigItem( "bots_allowspawning",
	{
	Name = "Easy Bot Connections",
	Category = "Bots",
	default = true,
	type = "boolean",
	desc = "Allow bots to be added with a click of a button",
	tags = {"toggle"}
	}
)

AddConfigItem( "bots_maxrecordingtime",
	{
	Name = "Max Bot Path Recording Time",
	Category = "Bots",
	default = 40,
	min = 10,
	max = 600,
	type = "integer",
	desc = "Maximum time (in seconds) a player has to record a bot path before it auto-stops (and saves)",
	}
)




-- end


if SERVER then
	local _R = debug.getregistry()
	function _R.Player:BotTalk( msg )
		for k,v in next, player.GetHumans() do
			PROPKILL.ChatText( v, team.GetColor( self:Team() ), self:Nick(), color_white, ": " .. msg )
		end
	end


	hook.Add( "PlayerInitialSpawn", "kickbots", function( pl )
		local pls = #player.GetAll()
		local bos = #player.GetBots()

		-- change to 1
		if pls - bos > PROPKILL.Config[ "bots_maxplayers" ].default then
			for k,v in pairs( player.GetBots() ) do
				v:Kick( " NO LONGER WELCOME " )
			end
		end

		timer.Create( "LETSODTHIS" .. pl:UserID(), 1, 1, function()
			if IsValid( pl ) and pl:IsBot() then
				pl:BotTalk( "let's do this" )
			end
		end )
	end )
elseif CLIENT then
	BOTPATHS_RECORDINGS = BOTPATHS_RECORDINGS or {}
	BOTPATHS_ISPLAYERRECORDING = BOTPATHS_ISPLAYERRECORDING or false

	net.Receive( "props_BotPaths_NetworkAllPaths", function()
			-- Start off with fresh slate
		BOTPATHS_RECORDINGS = {}

		local LoopCount = net.ReadUInt( 5 )
		for i=1,LoopCount do
			local PathID = net.ReadString()
			local IsActive = net.ReadBool()
			local CreatorID = net.ReadUInt64()
			local CreatedTime = net.ReadUInt( 32 )

			BOTPATHS_RECORDINGS[ PathID ] = {ActivePath=IsActive, Creator=CreatorID, CreatorTime=CreatedTime}
		end
		hook.Run( "props_BotPaths_PathInfoChanged" )
	end )
		-- Specifically this is just for removing a path
	net.Receive( "props_BotPaths_NetworkPath", function()
		local PathID = net.ReadString()
		BOTPATHS_RECORDINGS[ PathID ] = nil
		hook.Run( "props_BotPaths_PathInfoChanged", PathID )
	end )

	net.Receive("props_BotPaths_NetworkRecording", function()
		local PathID = net.ReadString()
		local IsRecording = net.ReadBool()

			-- For if player reopens menu
		BOTPATHS_ISPLAYERRECORDING = IsRecording

		hook.Run( "props_BotPaths_NetworkRecording", PathID, IsRecording )
	end )

	hook.Add("props_BotPaths_NetworkRecording", "props_ShowPathCountdownTimer", function( pathid, recording )
		if recording then
			LocalPlayer().PathCreationTimer = CurTime() + PROPKILL.Config["bots_maxrecordingtime"].default
		end
	end )

	AddClientConfigItem( "props_BotPathHUD",
		{
		Name = "Show Bot Path Countdown",
		default = true,
		type = "boolean",
		desc = "Show the Bot Path Countdown timer when recording a path",
		}
	)
		-- Typically we use VGUI elements but this is such a small thing we're just gonna do the old fashioned HUD
	hook.Add("HUDPaint", "props_ShowPathCountdownTimer", function()
		if not BOTPATHS_ISPLAYERRECORDING then return end
		if not PROPKILL.ClientConfig["props_BotPathHUD"].currentvalue then return end

		local BackgroundBoxWidth = 120
		local BackgroundBoxTall = 30
		local BackgroundBoxStartX = ScrW() - BackgroundBoxWidth - 5
		local BackgroundBoxStartY = 5
		draw.RoundedBox( 0, BackgroundBoxStartX, BackgroundBoxStartY, BackgroundBoxWidth, BackgroundBoxTall, Color( 27, 26, 26, 235 ) )

		local CountdownText = string.FormattedTime(LocalPlayer().PathCreationTimer - CurTime(), "%02i:%02i" )
		local TextSizeW,TextSizeH = surface.GetTextSize( CountdownText, "props_HUDTextSmall" )

		draw.SimpleText( CountdownText, "props_HUDTextSmall",
			BackgroundBoxStartX + (BackgroundBoxWidth - TextSizeW) / 2,
			BackgroundBoxStartY + (BackgroundBoxTall - TextSizeH) / 2,
			color_white, 0, 0
		)
	end )

end


if not ulx then return end

local CATEGORY_NAME = "Propkill"

function ulx.pkBot( calling_ply )
	if #player.GetBots() > 0 then return end
	local pls = #player.GetAll()
	local bos = #player.GetBots()
		-- change to 1
	if pls - bos > PROPKILL.Config[ "bots_maxplayers" ].default then return end

	game.ConsoleCommand( "bot\n" )

	ulx.fancyLogAdmin( calling_ply, "#A spawned a bot!" )
end
local pkBot = ulx.command( CATEGORY_NAME, "ulx pkbot", ulx.pkBot, "!bot" )
pkBot:defaultAccess( ULib.ACCESS_ALL )
pkBot:help( "Spawns a bot." )
