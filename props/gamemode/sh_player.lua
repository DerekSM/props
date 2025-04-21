--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Shared player extension
]]--

local _R = debug.getregistry()

NOTIFY_GENERIC = 0
NOTIFY_ERROR = 1
NOTIFY_UNDO = 2
NOTIFY_HINT = 3
NOTIFY_CLEANUP = 4

if SERVER then
	util.AddNetworkString( "props_NotifyPlayer" )
	util.AddNetworkString( "props_ConsoleNotify" )
end

function _R.Player:Notify( type, len, msg, consoleprint )
	if consoleprint then self:PrintMessage( HUD_PRINTCONSOLE, msg ) end
	
	if SERVER then
		net.Start( "props_NotifyPlayer" )
			net.WriteUInt( type, 4 )
			net.WriteUInt( len, 4 )
			net.WriteString( msg )
		net.Send( self )
	else
		notification.AddLegacy( msg, type, len )
	end
end

if CLIENT then
	net.Receive( "props_NotifyPlayer", function()
		local type = net.ReadUInt( 4 )
		local len = net.ReadUInt( 4 )
		local msg = net.ReadString()
		
		notification.AddLegacy( msg, type, len )
	end )
end

function _R.Player:ConsoleMsg( color, msg )
	if SERVER then
		net.Start( "props_ConsoleNotify" )
			net.WriteUInt( color.r, 8 )
			net.WriteUInt( color.g, 8 )
			net.WriteUInt( color.b, 8 )
			net.WriteString( msg )
		net.Send( self )
	else
		MsgC( color, msg .. "\n" )
	end
end

if CLIENT then
	net.Receive( "props_ConsoleNotify", function()
		local r,g,b = net.ReadUInt( 8 ), net.ReadUInt( 8 ), net.ReadUInt( 8 )
		local msg = net.ReadString()
		
		MsgC( Color( r, g, b, 255 ), msg .. "\n" )
	end )
end

--[[

*

* Total kills / deaths

*

--]]

function _R.Player:GetTotalFrags()
	return self:GetNW2Int( "TotalFrags", 0 )
end
function _R.Player:SetTotalFrags( i_Amt, b_Network )
	self:SetNW2Int( "TotalFrags", i_Amt )
end

function _R.Player:GetTotalDeaths()
	return self:GetNW2Int( "TotalDeaths", 0 )
end
function _R.Player:SetTotalDeaths( i_Amt )
	self:SetNW2Int( "TotalDeaths", i_Amt )
end

--[[

*

* Killstreaks

*

--]]

function _R.Player:GetKillstreak()
		-- turn into netrequest, nobody else needs to know about this unless spectating 
	return self:GetNW2Int( "Killstreak", 0 )
end
function _R.Player:AddKillstreak( i_Amt )
	--self:SetNetVar( "Killstreak", self:GetNetVar( "Killstreak", 0 ) + i_Amt )
	local Killstreak = self:SetKillstreak( self:GetKillstreak() + i_Amt )
	
	--if self:GetNetVar( "Killstreak", 0 ) > self:GetNetVar( "BestKillstreak", 0 ) and not PROPKILL.Battling then
	if Killstreak > self:GetBestKillstreak() and not PROPKILL.Battling then
		self:SetBestKillstreak( Killstreak )
	end
end
function _R.Player:SetKillstreak( i_Amt )
	--if PROPKILL.Battling then return end

	self:SetNW2Int( "Killstreak", i_Amt )
	
	if not PROPKILL.Battling then
		if i_Amt > self:GetBestKillstreak() then
			self:SetBestKillstreak( i_Amt )
		end
	end

	return i_Amt
end
function _R.Player:GetBestKillstreak()
	return self:GetNW2Int( "BestKillstreak", 0 )
end
function _R.Player:SetBestKillstreak( i_Amt )
	self:SetNW2Int( "BestKillstreak", i_Amt )
	
	if PROPKILL.Statistics[ "bestkillstreak" ] and PROPKILL.Statistics[ "bestkillstreak" ] < i_Amt then
		PROPKILL.Statistics[ "bestkillstreak" ] = i_Amt
		PROPKILL.Statistics[ "bestkillstreaker" ] = self:SteamID()
	end
end


function _R.Player:GetDeathstreak()
	return self:GetNW2Int( "Deathstreak", 0 )
end
function _R.Player:AddDeathstreak( i_Amt )
	local Deathstreak = self:SetDeathstreak( self:GetDeathstreak() + i_Amt)
	
	if Deathstreak > self:GetBestDeathstreak() and not PROPKILL.Battling then
		self:SetBestDeathstreak( i_Amt )
	end
end
function _R.Player:SetDeathstreak( i_Amt )
	if PROPKILL.Battling then return end

	self:SetNW2Int( "Deathstreak", i_Amt )
	
	if not PROPKILL.Battling then
		if i_Amt > self:GetBestDeathstreak() then
			self:SetBestDeathstreak( i_Amt )
		end
	end

	return i_Amt
end
function _R.Player:GetBestDeathstreak()
	return self:GetNW2Int( "BestDeathstreak", 0 )
end
function _R.Player:SetBestDeathstreak( i_Amt )
	self:SetNW2Int( "BestDeathstreak", i_Amt )
	
	if PROPKILL.Statistics[ "bestdeathstreak" ] and PROPKILL.Statistics[ "bestdeathstreak" ] < i_Amt then
		PROPKILL.Statistics[ "bestdeathstreak" ] = i_Amt
		PROPKILL.Statistics[ "bestdeathstreaker" ] = self:SteamID()
	end
end


--[[

*

* Leaders

*

--]]

local leader = NULL
function _R.Player:IsLeader()
	if IsValid( leader ) and leader == self then
		return true
	end
	
	return false
end

function props_GetLeader()
	if IsValid( leader ) and leader:GetKillstreak() > 0 then
		return leader
	end
	
		-- new lookup
	leader = NULL
	local temp_Killstreak = 0
	for k,v in pairs( player.GetAll() ) do
		if v:GetKillstreak() > temp_Killstreak then
			leader = v
			temp_Killstreak = v:GetKillstreak()
		end
	end
	
	return IsValid( leader ) and leader or NULL
end

				
--[[if CLIENT then
	net.Receive( "PK_UpdateKillstreak", function()
		-- move this elsewhere?
		local pl = net.ReadEntity()
		local killstreak = net.ReadUInt( 16 )
		local bestkillstreak = net.ReadUInt( 16 )
		
		pl:SetKillstreak( killstreak )
		pl.BestKillstreak = bestkillstreak
	end )
end]]

function _R.Player:GetKD()
	local frags, deaths = self:GetTotalFrags(), self:GetTotalDeaths()
	local round = math.Round( frags / deaths, 2 )
	
	return (frags == 0 and deaths == 0 and 0) or (tostring(round) == "inf" and 1) or round
end


function _R.Player:GetFightsWon()
	return self:GetNW2Int( "FightsWon", 0 )
end

function _R.Player:SetFightsWon( num )
	self:SetNW2Int( "FightsWon", num )
end

function _R.Player:AddFightsWon( num )
	self:SetFightsWon( self:GetFightsWon() + 1 )
end

function _R.Player:GetFightsLost()
	return self:GetNW2Int( "FightsLost", 0 )
end

function _R.Player:SetFightsLots( num )
	self:SetNW2Int( "FightsLost", num )
end

function _R.Player:AddFightsLost( num )
	self:SetFightsLost( self:GetFightsLost() + 1 )
end
