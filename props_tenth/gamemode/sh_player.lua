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
if SERVER then
	--util.AddNetworkString( "props_NetworkTotalFrags" )
end

function _R.Player:TotalFrags()
	--return self.propsTotalFrags or 0
	return self:GetNetVar( "TotalFrags", 0 )
end
function _R.Player:SetTotalFrags( i_Amt, b_Network )
	--[[self.propsTotalFrags = i_Amt
	if b_Network and SERVER then
		net.Start( "props_NetworkTotalFrags" )
			net.WriteEntity( self )
			net.WriteUInt( self.propsTotalFrags, 20 )
		net.Broadcast()
	end]]
	self:SetNetVar( "TotalFrags", i_Amt )
end

--[[if CLIENT then
	net.Receive( "props_NetworkTotalFrags", function()
		local ent = net.ReadEntity()
		local amt = net.ReadUInt( 20 )
		
		ent:SetTotalFrags( amt )
	end )
end]]

function _R.Player:TotalDeaths()
	--return self.propsTotalDeaths or 0
	return self:GetNetVar( "TotalDeaths", 0 )
end
function _R.Player:SetTotalDeaths( i_Amt )
	--self.propsTotalDeaths = i_Amt 
	self:SetNetVar( "TotalDeaths", i_Amt )
end

--[[

*

* Accuracy ( hits / props spawned )

*

--]]
--[[if SERVER then
	util.AddNetworkString( "props_RequestAccuracy" )
	util.AddNetworkString( "props_NetworkAccuracy" )
	
		-- spectators need to know this
	net.Receive( "props_RequestAccuracy", function( len, pl )
		local ent = net.ReadEntity()
		if not ent or not ent:IsPlayer() then
			return
		end
		
		pl.lastAccuracyRequest = pl.lastAccuracyRequest or {}
		
		if pl.lastAccuracyRequest[ ent ] and pl.lastAccuracyRequest[ ent ] > CurTime() then
			return
		end
		
		pl.lastAccuracyRequest[ ent ] = CurTime() + 5
		
		net.Start( "props_NetworkAccuracy" )
			net.WriteEntity( ent )
			net.WriteFloat( ent:Accuracy() )
		net.Send( pl )
	end )
end

function _R.Player:Accuracy()
	return self.propsAccuracy or 0
end

function _R.Player:SetAccuracy( i_Amt )
	self.propsAccuracy = math.Round( i_Amt, 2 )
end

if CLIENT then
	net.Receive( "props_NetworkAccuracy", function()
		local ent = net.ReadEntity()
		local accuracy = net.ReadFloat()
		
		ent:SetAccuracy( accuracy )
	end )
end]]

--[[

*

* Killstreaks

*

--]]

function _R.Player:GetKillstreak()
		-- turn into netrequest, nobody else needs to know about this unless spectating 
	return self:GetNetVar( "Killstreak", 0 )
end
function _R.Player:AddKillstreak( i_Amt )
	self:SetNetVar( "Killstreak", self:GetNetVar( "Killstreak", 0 ) + i_Amt )
	
	if self:GetNetVar( "Killstreak", 0 ) > self:GetNetVar( "BestKillstreak", 0 ) then
		self:SetNetVar( "BestKillstreak", self:GetNetVar( "Killstreak", 0 ) )
	end
end
function _R.Player:SetKillstreak( i_Amt )
	self:SetNetVar( "Killstreak", i_Amt )
	
	if not PROPKILL.Battling then
		if i_Amt > self:GetNetVar( "BestKillstreak", 0 ) then
			self:SetNetVar( "BestKillstreak", i_Amt )
		end
	end
end
function _R.Player:SetBestKillstreak( i_Amt )
	self:SetNetVar( "BestKillstreak", i_Amt )
end
function _R.Player:GetBestKillstreak()
	return self:GetNetVar( "BestKillstreak", 0 )
end

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
	local frags, deaths = self:TotalFrags(), self:TotalDeaths()
	local round = math.Round( frags / deaths, 2 )
	
	return (frags == 0 and deaths == 0 and 0) or (round == "inf" and 1) or round
end

