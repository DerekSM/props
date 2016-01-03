--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Player extensions
]]--

local _R = debug.getregistry()

--[[

*

* Killstreaks

*

--]]
	-- wtf was i thinking
--[[function _R.Player:CheckKillstreak()
	local killstreak = self:GetKillstreak()
	local found = ""
	for k,v in ipairs( PROPKILL.Killstreaks ) do
		if killstreak >= k then
			found = v
		end
	end
	
	return found != "" and true or false, found
end]]

--[[function _R.Player:UpdateKillstreak()
	--local killstreak = self:CheckKillstreak()
	net.Start("PK_UpdateKillstreak")
		net.WriteEntity( self )
		net.WriteInt( self:GetKillstreak(), 16 )
		--net.WriteString( killstreak )
		net.WriteInt( self:GetBestKillstreak(), 16 )
	net.Broadcast()
end]]

--[[

*

* Registering / Checking player kill types

*

--]]
oldSetFrags = oldSetFrags or _R.Player.SetFrags
function _R.Player:SetFrags( i_Amt )
	if not self:IsBot() then
			-- use totalfrags, totaldeaths?
		PROPKILL.TopPlayersCache[ self ] =
		{
			Kills = i_Amt,
			Deaths = self:Deaths(),
			SteamID = self:SteamID(),
		}
	end
	
		-- don't network for every kill,
		-- client's can do this themselves
	self:SetTotalFrags( self:TotalFrags() + i_Amt )
	--self:SetTotalFrags( self:GetTotalFrags() + i_Amt )
	
	oldSetFrags( self, i_Amt )
end

oldAddFrags = oldAddFrags or _R.Player.AddFrags
function _R.Player:AddFrags( i_Amt )
	if not self:IsBot() then
			-- use totalfrags, totaldeaths?
		PROPKILL.TopPlayersCache[ self ] =
		{
			Kills = self:Frags() + i_Amt,
			Deaths = self:Deaths(),
			SteamID = self:SteamID(),
		}
	end
	
		-- don't network for every kill,
		-- client's can do this themselves
	self:SetTotalFrags( self:TotalFrags() + i_Amt )
	--self:SetTotalFrags( self:GetTotalFrags() + i_Amt )
	
	oldAddFrags( self, i_Amt )
end

oldSetDeaths = oldSetDeaths or _R.Player.SetDeaths
function _R.Player:SetDeaths( i_Amt )
	self:SetTotalDeaths( self:TotalDeaths() + i_Amt )
	
	oldSetDeaths( self, i_Amt )
end

oldAddDeaths = oldAddDeaths or _R.Player.AddDeaths
function _R.Player:AddDeaths( i_Amt )
	self:SetTotalDeaths( self:TotalDeaths() + i_Amt )
	--self:SetTotalDeaths( self:GetTotalDeaths() + i_Amt )
	
	oldAddDeaths( self, i_Amt )
end
	
function _R.Player:AddFlybys( i_Amt )
	--self.Flybys = (self.Flybys or 0) + 1
	self:SetNetVar( "Flybys", self:GetNetVar( "Flybys", 0 ) + 1 )
end
function _R.Player:SetFlybys( i_Amt )
	--self.Flybys = i_Amt
	self:SetNetVar( "Flybys", i_Amt )
end
function _R.Player:GetFlybys()
	--return self.Flybys or 0
	return self:GetNetVar( "Flybys", 0 )
end

function _R.Player:AddLongshots( i_Amt )
	--self.Longshots = (self.Longshots or 0) + 1
	self:SetNetVar( "Longshots", self:GetNetVar( "Longshots", 0 ) + 1 )
end
function _R.Player:SetLongshots( i_Amt )
	--self.Longshots = i_Amt
	self:SetNetVar( "Longshots", i_Amt )
end
function _R.Player:GetLongshots()
	--return self.Longshots or 0
	return self:GetNetVar( "Longshots", 0 )
end

function _R.Player:IsFlying()
		-- Partially taken from DeathZone. My old method was bad.
	if self:IsOnGround() or self:WaterLevel() > 0
	or self.IsJumping
	or (self:GetVelocity()[1] < 300 and self:GetVelocity()[2] < 300) then return false end
	
	local tr = {}
	tr.start = self:EyePos()
	tr.endpos = self:EyePos() + Vector( 0, 0, 256 )
	tr.filter = { self }
	
	local trace = util.TraceLine( tr )
	
	if trace.HitWorld or IsValid( trace.Entity ) then
		return false
	else
		return true
	end
end
hook.Add( "KeyPress", "detectifjumping", function( pl, key )
	if key == IN_JUMP then
		pl.IsJumping = true
		timer.Create( "PK_ResetPlayerJump" .. tostring( pl:UserID() ), 0.3, 1, function()
			if not IsValid( pl ) then return end
			pl.IsJumping = false
		end )
	end
end )

--[[

*

* Registering Player killer

*

--]]
function _R.Player:GetNearestProp()
	local eFound = NULL
	local mindist = math.huge

	for k,v in next, ents.FindByClass("prop_physics") do
		local dist = (self:GetPos() - v:GetPos()):LengthSqr()
		if dist < mindist then
			mindist = dist
			eFound = v
		end
	end
	
	return eFound
end
	
--[[

*

* Player Cleanups

*

--]]
function _R.Player:Cleanup()
	if not self.Entities then return end
	for k,v in next, self.Entities do
		if IsValid(v) and v:GetClass() == "prop_physics" then
			v:Remove()
			self.Entities[ k ] = nil
		end
	end
end


--[[

*

* Battling

*

--]]
function _R.Player:SendBattleInvite( target, amt )
	self.BattleAmount = kills
	target.BattleAmount = kills

	net.Start( "props_FightInvite" )
		net.WriteUInt( self:UserID(), 12 )
		net.WriteString( self:Nick() )
		net.WriteUInt( amt or PROPKILL.Config[ "battle_defaultkills" ].default )
	net.Send( target )
end