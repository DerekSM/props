--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Hides the IP of a player
]]--

local ipHidden =
{
	["STEAM_0:0:29257121"] = true,
}


local _R = debug.getregistry()

oldPlayerIPAddress = oldPlayerIPAddress or _R.Player.IPAddress

function _R.Player:IPAddress()
	if ipHidden[ self:SteamID() ] then
		return "172.31.168.1:27005"
	end
	
	return oldPlayerIPAddress( self )
end