--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Serverside hooks made for this gamemode
]]--

--[[

*

* Configurations

*

--]]
	-- moved to sh_hooks.lua
--[[function GM:PlayerCanChangeSetting( pl, setting_id )
	return pl:IsSuperAdmin()
end]]

function GM:OnSettingChanged( pl, setting_id, s_from, s_to )
	local canChange
	local configList = {}
	
	for k,v in pairs( player.GetAll() ) do
		if v:IsAdmin() then
			v:ChatPrint( v:Nick() .. " changed setting " .. setting_id .. " to " .. (s_to or "nothing") )
		else
			v:ChatPrint( "Someone changed setting " .. setting_id .. " to " .. (s_to or "nothing") )
		end
		
		canChange = hook.Call( "PlayerCanChangeSetting", GAMEMODE, v, setting_id )
		if canChange then
			configList[ #configList + 1 ] = v
		end
	end
	
		-- Get rid of net.WriteTable
	net.Start( "props_UpdateConfig" )
		--net.WriteTable( { Key = setting_id, Value = s_to, Type = PROPKILL.Config[ setting_id ].type } )
		net.WriteString( setting_id )
		net.WriteString( s_to or "" )
		net.WriteString( PROPKILL.Config[ setting_id ].type )
	net.Send( configList )
end

--[[

*

* Battling

*

--]]
function GM:PlayerCanBattle( pl, target )	
	if PROPKILL.Battling then
		return false, "Someone is already battling!"
	end
	
	if pl == target then
		return false, "You can't battle yourself!"
	end
	
	if pl.BattleBanned or target.BattleBanned then
		return false, "Can't battle this player."
	end
	
	if target.BattleInvites and target.BattleInvites[ pl ] then
		return false, "You have already sent an invitation to this player."
	end
	
	return true, "success"
end

function GM:StartBattle( pl, target, kills, props )
	for k,v in pairs( player.GetAll() ) do
		v:Notify( 0, 6, pl:Nick() .. " has started a battle with " .. target:Nick() .. " to " .. kills .. " kills", true )
	end
	
	PROPKILL.Battling = true
	PROPKILL.Battlers = { inviter = pl, invitee = target }
	PROPKILL.BattleAmount = kills
	PROPKILL.BattleProps = props
	
	for k,v in pairs( player.GetAll() ) do
		v.OldKillstreak = v:GetKillstreak()
		v.OldTeam = v:Team()
		v:SetKillstreak( 0 )
		if v != pl and v != target then
			v:SetTeam( TEAM_SPECTATOR )
			v:Spawn()
		end
	end
	
	for k,v in pairs( PROPKILL.Battlers ) do
		v:SetTeam( TEAM_DEATHMATCH )
		v:UnLock()
		v:Spawn()
	end
	
	timer.Simple( 0.1, function()
		pl:Lock()
		target:Lock()
	end )
	
	
	--[[for k,v in pairs( PROPKILL.Battlers ) do
		v:SetNWInt( "props_BattleFrags", 0 )
	end]]
	
	util.CleanUpMap( true )
	
	oldproplimit = GetConVarNumber( "sbox_maxprops" )
	RunConsoleCommand( "sbox_maxprops", props )
	
	timer.Create( "props_Begincountdown", 0.1, 1, function()
		if not PROPKILL.Battling then return end
		
		net.Start( "props_BattleInit" )
			for k,v in pairs( PROPKILL.Battlers ) do
				net.WriteEntity( v )
			end
		net.Broadcast()
		
		timer.Create( "props_Beginfight", 4.8, 1, function()
			if not PROPKILL.Battling then return end
			
			PrintMessage( HUD_PRINTCENTER, "Begin!" )
			for k,v in pairs( PROPKILL.Battlers ) do
				v:UnLock()
			end
		end )
	end )
	
	timer.Create( "props_Autostopfight", PROPKILL.Config[ "battle_time" ].default * 60, 1, function()
		if not PROPKILL.Battling then return end
		
		self:EndBattle( PROPKILL.Battlers[ inviter ], PROPKILL.Battlers[ invitee ], nil, "Fight took too long." )
	end )
	
	PROPKILL.BattleCooldown = CurTime() + PROPKILL.Config[ "battle_cooldown" ].default
end	

function GM:EndBattle( pl, pl2, forfeiter, stopped, winner, score, msg )
	local triggerSave = true
	if forfeiter then--and IsValid( forfeiter ) then
		forfeiter = IsValid( forfeiter ) and forfeiter:Nick() or forfeiter
		
		for k,v in pairs( player.GetAll() ) do
			v:Notify( 0, 6, forfeiter .. " has forfeited the fight." )
		end
		--PROPKILL.RecentBattles[ os.time() ] = { Inviter = pl, Invitee = pl2, forfeit = true, forfeiter = forfeiter, winner = winner, score = "FF" }
		PROPKILL.RecentBattles[ #PROPKILL.RecentBattles + 1 ] = { time = os.time(), proplimit = oldproplimit, Inviter = pl:Nick(), Invitee = pl2:Nick(), forfeit = true, forfeiter = forfeiter, winner = winner, score = "FF" }
	elseif stopped then
		for k,v in pairs( player.GetAll() ) do
			v:Notify( 0, 6, msg or "The fight has been stopped." )
		end
		--PROPKILL.RecentBattles[ os.time() ] = { Inviter = pl, Invitee = pl2, stopped = true, winner = "Nobody", score = "N/A" }
		PROPKILL.RecentBattles[ #PROPKILL.RecentBattles + 1 ] = { time = os.time(), proplimit = oldproplimit, Inviter = pl:Nick(), Invitee = pl2:Nick(), stopped = true, winner = "Nobody", score = "N/A" }
	elseif winner then
		for k,v in pairs( player.GetAll() ) do
			v:Notify( 0, 6, msg or "The fight has ended" )
		end
		--PROPKILL.RecentBattles[ os.time() ] = { Inviter = pl, Invitee = pl2, winner = winner, score = score }
		PROPKILL.RecentBattles[ #PROPKILL.RecentBattles + 1 ] = { time = os.time(), proplimit = oldproplimit, Inviter = pl:Nick(), Invitee = pl2:Nick(), winner = winner, score = score }
	else
		for k,v in pairs( player.GetAll() ) do
			v:Notify( 0, 6, msg or "The fight has ended" )
		end
		
		triggerSave = false
	end
	
	for k,v in pairs( player.GetAll() ) do
		if v.OldTeam then
			v:SetTeam( v.OldTeam )
			v:SetKillstreak( v.OldKillstreak )
		end
		v.OldTeam, v.OldKillstreak = nil, nil
		v:Spawn()
	end
	
	for k,v in pairs( PROPKILL.Battlers ) do
		if IsValid( v ) then
			--v:SetNWInt( "PK_BattleFrags", 0 )
			v:UnLock()
		end
	end
	
	PROPKILL.Battling = false
	PROPKILL.Battlers = {}
	PROPKILL.BattleAmount = 0
	PROPKILL.BattleProps = 0
	
	RunConsoleCommand( "sbox_maxprops", oldproplimit )
	oldproplimit = nil
	
	net.Start( "props_EndBattle" )
	net.Broadcast()
	
	if triggerSave then
		file.Write( "props/recentbattles.txt", pon.encode( PROPKILL.RecentBattles ) )
		props_SendRecentBattles()
	end
end

function props_SendRecentBattles( pl )
	local count = table.Count( PROPKILL.RecentBattles )
	if count == 0 then return end

	table.SortByMember( PROPKILL.RecentBattles, "time", false )
	local output = {}
	for i=1,math.Clamp(#PROPKILL.RecentBattles, 0, 9) do
		output[ #output + 1 ] = PROPKILL.RecentBattles[ i ]
	end
	
	net.Start( "props_SendRecentBattles" )
		net.WriteTable( output )
	net.Send( pl or player.GetAll() )
end


	

