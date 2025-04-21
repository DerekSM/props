--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Credits Shinycow for making the gamemode
		
		pointless and dumb but my epeen is now 50 centimeters long
]]--

timer.Create( "props_CreditShinycow", 900, 0, function()
	
	for k,v in next, player.GetAll() do
		if not v.HasBeenAdvertised then
			v:ChatPrint( GAMEMODE.Name .. " v" .. GAMEMODE.Version .. " was brought to you by Shinycow" )
			v.HasBeenAdvertised = true
		end
	end

end )
