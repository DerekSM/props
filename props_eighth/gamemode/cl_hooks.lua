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



net.Receive( "props_BattleInit", function()
	print( "RECEIVED BACTLE INIT" )
	local battler1 = net.ReadEntity()
	local battler2 = net.ReadEntity()
	
	PROPKILL.Battling = true
	PROPKILL.Battlers[ "inviter" ] = battler1
	PROPKILL.Battlers[ "invitee" ] = battler2
	
	surface.PlaySound("vo/k_lab/kl_initializing.wav")
		-- wow this is cool!!
	timer.Simple(0.008, function()
		surface.PlaySound("vo/k_lab/kl_initializing.wav")
	end)
	hook.Add("HUDPaint", "propkill_BattleInit", function()
		draw.SimpleText( "Prepare to Battle", "ScoreboardDefaultTitle", (ScrW() * 0.5) - ( surface.GetTextSize( "Preparing Battle...", "ScoreboardDefaultTitle" ) * 0.5), ScrH() * 0.3, color_white, 0, 0 )
	end)
	timer.Simple(4.8, function()
		hook.Remove("HUDPaint", "propkill_BattleInit")
	end)
	
	PROPKILL.BattleTime = PROPKILL.Config[ "battle_time" ].default * 60
	timer.Simple( 0.8, function()
		timer.Create( "props_Battlecountdown", 1, PROPKILL.BattleTime, function()
			PROPKILL.BattleTime = PROPKILL.BattleTime - 1
		end )
	end )
	props_ShowBattlingHUD()
end)

net.Receive( "props_EndBattle", function()
	PROPKILL.Battling = false
	
	props_HideBattlingHUD()
end )