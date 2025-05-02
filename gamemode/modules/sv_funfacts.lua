--[[
				  _________.__    .__
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     /
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/
						\/      \/        \/\/         \/

		Some dumb facts about the gamemode and propkilling.
]]--

local ReferenceTable =
{
"You can click the Achievements header to change sorting.",
"You can click on any achievement to view it's description, difficulty, and (if completed) a button to announce completion.",
"Running \"props_achievements\" in console will broadcast your number of achievements completed.",
"You can right click recent battle results to view the steam page of the battlers.",
"You can right click icons in the Top Props menu to copy the model.",
"This gamemode was first developed around 2014.",
"Propkilling directly influenced the development of the DarkRP gamemode.",
"The developer's (Shinycow) first interaction with propkilling was from a dude named Ultra in ~2011.",
"The reason there's multiple different propkilling gamemodes is because Australians are fags.",
"You can reset your stats by typing \"props_resetmystats\" in console. This won't affect achievements.",
"You can remove all your props at once by typing \"undoall\" or \"gmod_cleanup props\" in console.",
"Server admins can use the context menu to (un)block props.",
}


    -- We'll tell them a fun fact only one time.
hook.Add("PlayerInitialSpawn", "propsGamemodeFunFacts", function( pl )
    timer.CreatePlayer(pl, "funfacts", 1, 1, function()
        local TableSelection = math.random(1, #ReferenceTable)

        PROPKILL.ChatText( pl, PROPKILL.Colors.Blue, "Props: ", PROPKILL.Colors.Yellow, "Did you know? " .. ReferenceTable[TableSelection] )
    end)
end )

