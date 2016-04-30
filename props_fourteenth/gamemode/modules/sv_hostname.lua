--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              
						
		Changes server name in random intervals.
		Modify the table to your liking.
]]--

local hostnames =
{
"Shinycow's Propkill | Denver USA", 
"Shinycow's Propkill | 100%% More File Stealing",
"Shinycow's Propkill | Featuring: You're just a delusion!!",
"Shinycow's Propkill | ScriptFodder Edition",
"Shinycow's Propkill | Now with Bots 02 and 03",
"Shinycow's Propkill | Denver USA",
}
local i = 1
local function ChangeHostname()
	i = i + 1
	if i > #hostnames then
		i = 1
	end
	RunConsoleCommand("hostname", hostnames[ i ])

	timer.Simple(math.random(45,115), function()
		ChangeHostname()
	end)
end
ChangeHostname()
