--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Saving and Loading of player data
]]--

local _R = debug.getregistry()

function _R.Player:SavePropkillData()
	local steamid = string.gsub( self:SteamID(), ":", "_" )
	
	local data = 
	{
	self:GetTotalFrags(),
	self:GetTotalDeaths(),
	
	self:GetFlybys(),
	self:GetLongshots(),
	self:GetHeadsmash(),
	
	self:GetBestKillstreak(),
	self:GetBestDeathstreak(),
	
	self:GetFightsWon(),
	self:GetFightsLost()
	}
	
	file.Write( "props/" .. steamid .. ".txt", pon.encode( data ) )
end


local dataset =
{
_R.Player.SetTotalFrags,
_R.Player.SetTotalDeaths,

_R.Player.SetFlyby,
_R.Player.SetLongshot,
_R.Player.SetHeadsmash,

_R.Player.SetBestKillstreak,
_R.Player.SetBestDeathstreak,

_R.Player.SetFightsWon,
_R.Player.SetFightsLost,
}

function _R.Player:LoadPropkillData()
	local steamid = string.gsub( self:SteamID(), ":", "_" )
	
	if file.Exists( "props/" .. steamid .. ".txt", "DATA" ) then
		
		local data = pon.decode( file.Read( "props/" .. steamid .. ".txt", "DATA" ) )

		for i=1,#dataset do
			if not data[ i ] then
				print( [[ERROR LOADING PLAYER DATA: ]] .. self:Nick() .. [[ (]] .. self:SteamID() .. [[ )
				            Couldn't load number ]] .. i )
				return
			end
			
			dataset[ i ]( self, data[ i ] )
		end

	end
end

-- APR 2025 added this because I forgot we already did a full update in PlayerInitialSpawn
--[[net.Receive("props_RequestGamemodeConfigSync", function( len, pl )
	if not pl:IsAdmin() then return end
	if pl.SyncedGamemodeConfig then return end

	-- Unfortunately because of the way we designed our config system we will just have to send the whole table.
	net.Start("props_SendGamemodeConfigSync")
		-- No, WriteTable isn't ideal but they're in a menu and can only do this once so who cares?
		net.WriteTable(PROPKILL.Config)
	net.Send( pl )

	pl.SyncedGamemodeConfig = true
end)]]

function props_SaveGamemodeConfig()
	if not PROPKILL.HasSettingChangedRecently then return end

	local data = {}
	for k,v in next, PROPKILL.Config do
		if v.type == "boolean" or v.type == "integer" then
			data[k] = v.default
		end
	end

	file.Write( "props/config.txt", pon.encode( data ) )
end

function props_LoadGamemodeConfig()
	if file.Exists( "props/config.txt", "DATA" ) then

		local data = pon.decode( file.Read( "props/config.txt", "DATA" ) )

		for k,v in next, data do
			if PROPKILL.Config[ k ] then
				PROPKILL.Config[ k ].default = v
			end
		end
	end
end
