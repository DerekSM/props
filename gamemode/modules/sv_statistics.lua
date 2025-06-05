--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Statisics that the gamemode accumulates from normal playing.
		A lot of these are from older versions and so servers that update to this will show the old data! (This is good)
]]--

if not PROPKILL.Statistics then return end

local ReferenceTable =
{
["propspawns"] = "total props have been spawned acrossed restarts",
["totalheadsmash"] = "players had their heads smashed",
["totaljoins"] = "total returning players have joined",
["totaluniquejoins"] = "total unique players have joined.",
["totalkills"] = "total kills across restarts",
["totalmessages"] = "total messages have been said by players",
["totalfights"] = "total fights have been wagered",
["otherspawns"] = "total non-props have been spawned across restarts",
["totallongshot"] = "players have been longshot'd",
["totalflyby"] = "players have been flyby'd",
["totalsuicides"] = "players have killed themselves",
["totalsmash"] = "total non-special kills have been performed.",
}


timer.Create( "props_Statistics", 666, 0, function()
	local TempTable = {}
	for k,v in next, PROPKILL.Statistics do
		TempTable[#TempTable + 1 ] = k
	end
	local TableSelection = math.random(1, #TempTable)

		-- We have an unformatted stat but fuck it we'll display anyway
	if not ReferenceTable[TempTable[TableSelection]] then
		for k,v in pairs( player.GetAll() ) do
			PROPKILL.ChatText( v, PROPKILL.Colors.Blue,
				"Props: ", color_white,
				"Statistic \"" .. TempTable[TableSelection] .. "\" has recorded the number \"" .. PROPKILL.Statistics[TempTable[TableSelection]] .. "\"" )
		end
	else
		for k,v in pairs( player.GetAll() ) do
			PROPKILL.ChatText( v, PROPKILL.Colors.Blue,
			"Props Statistics: ", color_white, PROPKILL.Statistics[TempTable[TableSelection]] .. " " .. ReferenceTable[TempTable[TableSelection]] )
		end
	end
end )
