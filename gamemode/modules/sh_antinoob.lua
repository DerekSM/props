--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Handles anti-spawn blocking/killing.
			Removes frozen props in spawn
			Removes huge props in spawn
			Gives people babygod (can't be killed for a certain amount of time)
			
		Also adds configuration options so there's really no reason to remove this module
		
		Also features a whitelist, people in the whitelist
			Can circumvent the anti frozen props, huge props, and people with babygod.
]]--

	
--[[

*

* Configurables. These can all be modified in-game.

* Don't change unless you want to break something.

*

--]]

AddConfigItem( "babygod",
	{
	Name = "Babygod",
	default = true,
	Category = "Player Management",
	type = "boolean",
	desc = "When players spawn they will have temp godmode.",
	tags = {"temporary","antinoob"}
	}
)

AddConfigItem( "babygod_time",
	{
	Name = "Babygod Time",
	Category = "Player Management",
	default = 1.55,
	type = "integer",
	desc = "Spawned players have godmode for this long.",
	tags = {"babygod","temporary","antinoob"}
	}
)

AddConfigItem( "spawnprotection", 
	{
	Name = "Spawn Protection",
	Category = "Player Management",
	default = true,
	type = "boolean",
	desc = "Toggle anti-spawnblock.",
	tags = {"antinoob"}
	}
)

	-- How many units from spawn to check for
	-- This only applies to legacy system. New spawnpoints created with toolgun don't use this.
props_antinoobdetectionRadius = 305^2

	-- whitelist
props_antinoobwhitelist =
{
		-- Shinycow
	--"STEAM_0:0:29257121",
}
