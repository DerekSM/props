--[[

*

* Clientside player death

*

--]]

net.Receive( "props_NetworkPlayerKill", function()
	local dead = net.ReadEntity()
	local killer = net.ReadEntity()
		-- smash / longshot / flyby
	local kill_type = net.ReadString()
	
	hook.Call( "OnPlayerKilled", nil, dead, killer, kill_type )
end )

--[[
	EXAMPLE USES:
		Writing a clientside kill system to track how many people you have killed
		and by what type.
		
		The above is possible without this by using gameevent.Listen( "player_death" ),
		however it is a lot easier this way.
	

	EXAMPLE CODE:
	
		hook.Add( "OnPlayerKilled", "example", function( plDead, plKiller, sType )
			print( plDead:Nick() .. " was killed by " .. plKiller:Nick() .. " with type " .. sType )
		end )
]]--

function GM:OnPlayerKilled( dead, killer, kill_type )
	if dead != killer then
		killer:SetTotalFrags( killer:TotalFrags() + 1 )
		--killer:SetTotalFrags( killer:GetTotalFrags() + 1 )
	end
	dead:SetTotalDeaths( dead:TotalDeaths() + 1 )
	--dead:SetTotalDeaths( dead:GetTotalDeaths() + 1 )
	
	--[[if killer == LocalPlayer() then
		net.Start( "props_RequestAccuracy" )
			net.WriteEntity( LocalPlayer() )
		net.SendToServer()
	end]]
end


--[[

*

* Configuration Settings

*

--]]
net.Receive( "props_UpdateConfig", function()
	local setting = net.ReadString()
		-- if nothing it is ""
	local new_value = net.ReadString()
	local setting_type = net.ReadString()
	
	if new_value == "" then return end
	
	if setting_type == "integer" then
		PROPKILL.Config[ setting ].default = tonumber( new_value )
	elseif setting_type == "boolean" then
		PROPKILL.Config[ setting ].default = tobool( new_value )
	end
end )