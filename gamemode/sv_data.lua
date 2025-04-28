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

	else

		PROPKILL.Statistics[ "totaluniquejoins" ] = (PROPKILL.Statistics[ "totaluniquejoins" ] or 0) + 1

	end
end


	-- todo: allow saving progress if the achievement allows for it
	-- Should we also save the datatable?
function _R.Player:SaveCombatAchievements()
	if not PROPKILL.Config["achievements_save"].default then return end

	local steamid = string.gsub( self:SteamID(), ":", "_" )

		--[[
		["standyourground"]:
                ["Progress"]    =       0
                ["Unlocked"]    =       true
                ["UnlockedTime"]        =       1745851560
                ["datatable"]:

		]]
	local data = {}
	for k,v in next, self.AchievementData do
		if v.Unlocked then
			data[k] = {Unlocked=true,UnlockedTime=v.UnlockedTime}
		end
	end

	file.Write( "props/achievements/" .. steamid .. ".txt", pon.encode( data ) )
end

function _R.Player:LoadCombatAchievements()
	local steamid = string.gsub( self:SteamID(), ":", "_" )
	self.AchievementData = self.AchievementData or {}

	if file.Exists( "props/achievements/" .. steamid .. ".txt", "DATA" ) then

		local data = pon.decode( file.Read("props/achievements/" .. steamid .. ".txt", "DATA") )

		for k,v in next, data do
			self.AchievementData[ k ] = self.AchievementData[ k ] or {}
			self.AchievementData[ k ] = v
		end

	end
end

	-- Save completion data.
function props_SaveCombatAchievements()
	local data = {}
		-- Save it in table format to allow more information down the line, while maintaining backwards compatibility
	for k,v in next, PROPKILL.GetCombatAchievements() do
		data[ k ] = {numCompletions=v:GetCompletionRate()}
	end

	file.Write( "props/achievements/achievementdata.txt", pon.encode( data ) )
end

function props_LoadCombatAchievements()
	if file.Exists( "props/achievements/achievementdata.txt", "DATA" ) then
		local data = pon.decode( file.Read( "props/achievements/achievementdata.txt", "DATA" ) )

		for k,v in next, PROPKILL.GetCombatAchievements() do
			if data[k] then
				v:SetCompletionRate( data[k].numCompletions )
			end
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

	PROPKILL.HasSettingChangedRecently = false
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
