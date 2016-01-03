--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Makes bots follow a certain path and spawn props to simulate a propkilling environment
		
		... really all they do is prop surf around the map to allow players to practice

		todo: make it detect jumps
		todo: possibly make bots detect if they are in different position by like say a player or a prop:
			when setting their velocity, check if their pos from the new velocity is the same or CLOSE to the same as the old
			velocity and pos

			simple table checking i hope ^

		so it seems that the should pos and the actual player pos is different.
			maybe increasing the velocity of the bot replaying the movement will make it less profund??
			LETS DO IT!

		ALSO add callback to bot: pl:AddCallback( "PhysicsCollide", function( ent, data ) print ( data.HitEntity ) end )
			make the bot kill itself or something idk ahaha

			possibility: if the bot is like 30 units behind its SHOULD pos, set it to that pos if the player hasnt touched another physics entity.
			so .. yeah!!
]]--

	-- set cmd:SetMouseWheel to 90 -- this is what mine is set as

AddConfigItem( "bots_enable",
	{
	Name = "Enable bot surfing",
	default = true,
	type = "boolean",
	desc = "Allow bots to surf around the map",
	}
)

props_BotEnabled = props_BotEnabled or true
hook.Add( "InitPostEntity", "props_BotSurfCheckMap", function()
	--[[if game.GetMap() != "rp_downtown_v2_propkill_v1b" then
		props_BotEnabled = false
		return
	end]]
	file.CreateDir( "props/botpaths" )

	if file.Exists( "props/botpaths/" .. string.lower( game.GetMap() ) .. ".txt", "DATA" ) then
		RECORDING = pon.decode( file.Read( "props/botpaths/" .. string.lower( game.GetMap() ) .. ".txt" ) )
	else
		props_BotEnabled = false
	end
end )

--[[hook.Add( "PlayerSpawn", "props_BotSpawns", function( pl )
	if not props_BotEnabled or not pl:IsBot() then return end
	
		-- this is temporary, im just testing out shit
	timer.Create( "props_SetBotSpeed" .. pl:UserID(), 0.15, 1, function()
		if not IsValid( pl ) then return end
		
		pl:SetWalkSpeed( 2 )
		pl:SetRunSpeed( 2 )
	end )
end )]]

concommand.Add( "props_botpaths_save", function( pl )
	if not pl:IsSuperAdmin() then return end

	file.Write( "props/botpaths/" .. string.lower( game.GetMap() ) .. ".txt", pon.encode( RECORDING ) )
	pl:Notify( NOTIFY_GENERIC, 8, "Saved bot paths.", true )
end )

--[[hook.Add( "StartCommand", "props_BotTest", function( pl, cmd )
	if not props_BotEnabled or not pl:IsBot() then return end
	
	cmd:SetButtons( bit.bor( cmd:GetButtons(), IN_ATTACK ) )
end )]]

	-- RECORDING
	--		1 (first bot):
	--				first:
	--					replaypos
	--					startpos
	--					starteyes
	--					data:
	--						1:
	--							velocity
	--							eyes
	--							pos
	--						2:
	--							velocity
	--							eyes
	--							pos
	--				second:
	--					replaypos
	--					startpos
	--					starteyes
	--					data:
	--						1:
	--							velocity
	--							eyes
	--							pos
	--		2 (second bot):


RECORDING = RECORDING or {}
--RECORDING[ 1 ] = {}
--RECORDING_STARTPOS = RECORDING_STARTPOS or nil
--RECORDING_STARTEYES = RECORDING_STARTEYES or nil
concommand.Add( "props_record_reset", function( pl ) 
	if not IsValid( pl ) then return end
	if not arg[1] or not arg[1] == "yes" then
		pl:ChatPrint( "This will reset ALL bot paths. Use argument 'yes' to continue.")
		return
	end

	RECORDING = {}
end )
concommand.Add( "props_record_start", function( pl, cmd, arg )
	if not IsValid( pl ) then return end
	if not arg[1] or not arg[2] then 
		pl:ChatPrint( "Supply a bot # and a path\nCheck console for details")
		pl:PrintMessage( HUD_PRINTCONSOLE, "\nBot # and path examples:\nprops_record_start 1 first\nprops_record_start 1 second\nprops_record_start 2 first\n" )
		return
	end

	local botnum = tonumber( arg[ 1 ] )
	if not botnum then return end

	RECORDING[ botnum ] = RECORDING[ botnum ] or {}
	RECORDING[ botnum ][ arg[ 2 ] ] = RECORDING[ botnum ][ arg[ 2 ] ] or {}
	RECORDING[ botnum ][ arg[ 2 ] ][ "replayingpos" ] = 0
	RECORDING[ botnum ][ arg[ 2 ] ][ "startpos" ] = pl:GetPos()
	RECORDING[ botnum ][ arg[ 2 ] ][ "starteyes" ] = pl:EyeAngles()
	RECORDING[ botnum ][ arg[ 2 ] ][ "data" ] = {}
	pl.RecordMovement = { botnum = botnum, place = arg[ 2 ] }
	--RECORDING_STARTPOS = pl:GetPos()
	--RECORDING_STARTEYES = pl:EyeAngles()
	--REPLAYING_POS = 0
	--pl.RecordMovement = true
	pl:ChatPrint( "started" )
end )
concommand.Add( "props_record_stop", function( pl )
	pl.RecordMovement = nil
	pl:ChatPrint( "stopped" )
end )

concommand.Add( "props_replay_start", function( pl, cmd, arg )
	if not pl:IsSuperAdmin() then return end

	if not arg[1] or not arg[2] then 
		pl:ChatPrint( "Supply a bot # and a path\nCheck console for details")
		pl:PrintMessage( HUD_PRINTCONSOLE, "\nBot # and path examples:\nprops_replay_start 1 first\nprops_replay_start 1 second\nprops_replay_start 2 first\n" )
		return
	end

	pl.ReplayMarked = tonumber( arg[ 1 ] )
	pl.ReplayMovement = arg[ 2 ]
end )
concommand.Add( "props_replay_stop", function( pl )
	pl.ReplayMarked = nil
	pl.ReplayMovement = nil
	--REPLAYING_POS = 0
	pl.ReplayTrigger = false
end)

REPLAYING_POS = 0

hook.Add( "PlayerSpawn", "props_ReplayPlayerMovement", function( pl )
	if pl:IsBot() and pl.ReplayMarked then
		local values, key = table.Random( RECORDING[ pl.ReplayMarked ] )
		pl.ReplayMovement = key

		print( pl.ReplayMovement )
		if not RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "startpos" ] then return end
		pl:SetPos( RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "startpos" ] )
		pl:SetEyeAngles( RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "starteyes" ]  )
		timer.Create( "props_ReplayPlayerMovement", 0.1, 1, function()
			if not IsValid( pl ) then return end

			pl.ReplayTrigger = true
		end )

		pl.TouchedPhysics = nil

		if not pl.CallbackCreated then
			pl:AddCallback( "PhysicsCollide", function( ent, data )
				local vel = data.TheirOldVelocity
				if vel:Length() != 0 then
					pl.TouchedPhysics = {force = true}
				else
						-- dont check this way. makes the player glitch through.
						--		due to this only being called if they stop touching this prop and touch it again,
						--		or touch another prop

						-- instead, do it originally in this hook
						--	in the startcommand distance check, make it the second = true
						--	if their distance pos is greater than the FIRST great (
							--	eg if difference > 76 then
							-- but the difference would be greater since they're bein gheld back
							-- so make it like 'if difference > 85 then'
					if pl.TouchedPhysics and not pl.TouchedPhysics.second then
						pl.TouchedPhysics = {second = true}
					else
						pl.TouchedPhysics = {second = false}
					end
				end
			end )
			pl.CallbackCreated = true
		end
	end
end )

hook.Add( "DoPlayerDeath", "props_ReplayPlayerMovement", function( pl )
	if pl:IsBot() and pl.ReplayMovement then
		pl.ReplayMovement = nil
	end
end )

hook.Add( "StartCommand", "props_ReplayPlayerMovement", function( pl, cmd )
	if pl.RecordMovement then
		
		-- record player velocity, and eyeangles
		-- should do it ??
		--PrintTable( pl.RecordMovement )
		local movement_botnum = pl.RecordMovement[ "botnum" ]
		local movement_botplace = pl.RecordMovement[ "place" ]

		--PrintTable( RECORDING[ movement_botnum ][ movement_botplace ] )
		--print ( #RECORDING[ movement_botnum ][ movement_botplace ][ "data" ] )
		local buttons = cmd:GetButtons()
		local jumping = bit.band( buttons, IN_JUMP ) == IN_JUMP
		local ducking = bit.band( buttons, IN_DUCK ) == IN_DUCK

		RECORDING[ movement_botnum ][ movement_botplace ][ "data" ][ #RECORDING[ movement_botnum ][ movement_botplace ][ "data" ] + 1 ] = { velocity = pl:GetVelocity(), eyes = pl:EyeAngles(), pos = pl:GetPos(), jumping = jumping, crouching = ducking}
		--RECORDING[ movement_botnum ][ movement_botplace ][ "data" ][ #RECORDING[ movement_botnum ][ movement_botplace ][ "data" ] + 1 ] = { fakedata = true }
		--RECORDING[ #RECORDING + 1 ] = { velocity = pl:GetVelocity(), eyes = pl:EyeAngles(), pos = pl:GetPos() }

		return
	end


	if pl:IsBot() and pl.ReplayMovement then --pl.ReplayMovement then
		if not pl:Alive() then pl:Spawn() end
		if not pl.ReplayTrigger then return end

		local replaying_pos = RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "replayingpos" ] 

		if not (RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "data" ][ replaying_pos + 1 ]) then
			pl:ChatPrint( "finished" )
			--REPLAYING_POS = 0
			pl:Spawn()
			pl.ReplayTrigger = false
			RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "replayingpos" ] = 0
			print( RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "data" ][ 1 ].pos, pl:GetPos() )
			print( " finished" )
			--return
		end
		cmd:ClearMovement()
		--[[if not pl.ReplayTrigger then
			--if not RECORDING_STARTPOS then return end
			if not RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "startpos" ] then return end
			pl:SetPos( RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "startpos" ] )
			pl:SetEyeAngles( RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "starteyes" ]  )
			pl.ReplayTrigger = true
		end]]
		--REPLAYING_POS = REPLAYING_POS + 1
		RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "replayingpos" ] = RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "replayingpos" ]  + 1

		cmd:SetForwardMove( pl:GetMaxSpeed() )
		--pl:SetVelocity( RECORDING[ REPLAYING_POS ].velocity )
		if RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "data" ][ replaying_pos ] and RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "data" ][ replaying_pos ].eyes then
			pl:SetEyeAngles( RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "data" ][ replaying_pos ].eyes )--RECORDING[ REPLAYING_POS ].eyes )
		else
			print( "i dont even know.." )
		end



		--[[if RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "replayingpos" ] - 1 != 0 then --REPLAYING_POS - 1 !=  0 then
			if pl:GetPos():Distance( RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "data" ][ RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "replayingpos" ] - 1 ].pos ) > 1000 then--RECORDING[ REPLAYING_POS - 1 ].pos ) > 1000 then
				pl:ChatPrint( "U GOT MOVED?? ")
				--if not pl:Alive() then pl:Spawn() end
				--pl.ReplayMovement = false
				--REPLAYING_POS = 0
				RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "replayingpos" ] = 0
				pl.ReplayTrigger = false
				return
			end
		end]]

		--[[
				todo: possibly make bots detect if they are in different position by like say a player or a prop:
			when setting their velocity, check if their pos from the new velocity is the same or CLOSE to the same as the old
			velocity and pos

			simple table checking i hope ^
		]]

		local replaymovement = RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ]

		if replaymovement[ "data" ][ replaymovement[ "replayingpos" ] ].fakedata then 
			--print 'fakedata'
			return
		end

		--if RECORDING[ pl.ReplayMarked ] and RECORDING[ pl.ReplayMarked ][ pl.ReplayMarked ] then
			local jumping, ducking = replaymovement[ "data" ][ replaymovement[ "replayingpos" ] ].jumping, replaymovement[ "data" ][ replaymovement[ "replayingpos" ] ].crouching
			if jumping and ducking then
				cmd:SetButtons( IN_JUMP + IN_DUCK )
			elseif jumping then
				cmd:SetButtons( IN_JUMP )
			elseif ducking then
				cmd:SetButtons( IN_DUCK )
			end
			
			local velocity = RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "data" ][ RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "replayingpos" ]  ].velocity
			--local x, y, z = velocity.x, v
			--print( "test", x )
			--[[if velocity.x < 0 then velocity.x = velocity.x - 0.5 end
			if velocity.x > 0 then velocity.x = velocity.x + 0.5 end
			if velocity.y < 0 then velocity.y = velocity.y - 0.5 end
			if velocity.y > 0 then velocity.y = velocity.y + 0.5 end
			if velocity.z < 0 then velocity.z = velocity.z - 0.5 end
			if velocity.z > 0 then velocity.z = velocity.z + 0.5 end]]
			pl:SetVelocity( RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "data" ][ RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "replayingpos" ]  ].velocity - pl:GetVelocity() )--RECORDING[ REPLAYING_POS ].velocity - pl:GetVelocity() )
		--end

		--print( replaymovement[ "data" ][ 1 ].pos, replaymovement[ "startpos" ] )

			-- reimplement after making bots do the jump shit

		if RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "replayingpos" ] - 1 > 0 then --REPLAYING_POS - 1 !=  0 then
			local replaymovement = RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ]

			local shouldpos = replaymovement[ "data" ][ replaymovement[ "replayingpos" ] ].pos:Distance( replaymovement[ "data" ][ replaymovement[ "replayingpos" ] - 1 ].pos )

			local actualpos = pl:GetPos():Distance( replaymovement[ "data" ][ replaymovement[ "replayingpos" ] - 1 ].pos)

			local difference = math.abs( shouldpos - actualpos )

			--print( difference, shouldpos, actualpos )

			if difference > 76 then
				if pl.TouchedPhysics then --99.7 then --74 then
					if pl.TouchedPhysics.second or pl.TouchedPhysics.force then
						print( pl:Nick() .. " got moved ?? ", difference )
						RECORDING[ pl.ReplayMarked ][ pl.ReplayMovement ][ "replayingpos" ] = 0
						pl.ReplayTrigger = false
						pl:Spawn()
						return
					end
				else
					pl:SetPos( replaymovement[ "data" ][ replaymovement[ "replayingpos" ] ].pos )
				end
			end
		end

	end
end )
hook.Add( "PlayerTick", "props_RecordPlayerMovement", function( pl, mv)
		-- testing putting this in STartCommand instead
	if IsValid( pl ) then return end
	if pl.RecordMovement then
		
		-- record player velocity, and eyeangles
		-- should do it ??
		--PrintTable( pl.RecordMovement )
		local movement_botnum = pl.RecordMovement[ "botnum" ]
		local movement_botplace = pl.RecordMovement[ "place" ]

		--PrintTable( RECORDING[ movement_botnum ][ movement_botplace ] )
		--print ( #RECORDING[ movement_botnum ][ movement_botplace ][ "data" ] )
		local buttons = mv:GetButtons()
		local jumping = bit.band( buttons, IN_JUMP ) == IN_JUMP
		local ducking = bit.band( buttons, IN_DUCK ) == IN_DUCK

		RECORDING[ movement_botnum ][ movement_botplace ][ "data" ][ #RECORDING[ movement_botnum ][ movement_botplace ][ "data" ] + 1 ] = { velocity = pl:GetVelocity(), eyes = pl:EyeAngles(), pos = pl:GetPos(), jumping = jumping, crouching = ducking}
		--RECORDING[ #RECORDING + 1 ] = { velocity = pl:GetVelocity(), eyes = pl:EyeAngles(), pos = pl:GetPos() }

	end
end )


util.AddNetworkString( "props_DebugAutopilot" )
net.Receive( "props_DebugAutopilot", function( len, pl )
	local pos = net.ReadVector()
	local ang = net.ReadAngle()
	
	--[[pl:Freeze( true )
	
	timer.Create( "props_teleportplayer" .. pl:UserID(), 0.1, 1, function()
		if not IsValid( pl ) then return end]]
		pl:SetPos( pos )
		pl:SetEyeAngles( ang )
	--[[end )
	
	timer.Create( "props_unfreezeplayer" .. pl:UserID(), 1, 1, function()
		if not IsValid( pl ) then return end
		
		pl:Freeze( false )
	end )]]
end )


-- old

--[[hook.Add( "StartCommand", "props_ReplayPlayerMovement", function( pl, cmd )
	if pl.ReplayMovement then
		if not RECORDING[ REPLAYING_POS + 1 ] then
			pl:ChatPrint( "finished" )
			pl.ReplayMovement = false
			REPLAYING_POS = 0
			pl.ReplayTrigger = false
			return
		end
		cmd:ClearMovement()
		if not pl.ReplayTrigger then
			if not RECORDING_STARTPOS then return end
			pl:SetPos( RECORDING_STARTPOS )
			pl:SetEyeAngles( RECORDING_STARTEYES )
			pl.ReplayTrigger = true
		end
		REPLAYING_POS = REPLAYING_POS + 1

		cmd:SetForwardMove( pl:GetMaxSpeed() )
		--pl:SetVelocity( RECORDING[ REPLAYING_POS ].velocity )
		pl:SetEyeAngles( RECORDING[ REPLAYING_POS ].eyes )
		if pl:GetPos():Distance( RECORDING[ REPLAYING_POS - 1 ].pos ) > 42 then
			pl:ChatPrint( "U GOT MOVED?? ")
			pl.ReplayMovement = false
			REPLAYING_POS = 0
			pl.ReplayTrigger = false
			return
		end
		pl:SetPos( RECORDING[ REPLAYING_POS ].pos )
		--pl:SetViewAngles( RECORDING[ REPLAYING_POS ].eyes )
	end
end )]]

	------------- ABOVE WORKS ^ but is only for debugging purposes. this will make them continuously do it

--[[hook.Add( "StartCommand", "props_ReplayPlayerMovement", function( pl, cmd )
	if pl.ReplayMovement then
		if not RECORDING[ REPLAYING_POS + 1 ] then
			pl:ChatPrint( "finished" )
			pl.ReplayMovement = false
			REPLAYING_POS = 0
			pl.ReplayTrigger = false
			return
		end
		cmd:ClearMovement()
		if not pl.ReplayTrigger then
			if not RECORDING_STARTPOS then return end
			pl:SetPos( RECORDING_STARTPOS )
			pl:SetEyeAngles( RECORDING_STARTEYES )
			pl.ReplayTrigger = true
		end
		REPLAYING_POS = REPLAYING_POS + 1

		cmd:SetForwardMove( pl:GetMaxSpeed() )
		--pl:SetVelocity( RECORDING[ REPLAYING_POS ].velocity )
		pl:SetEyeAngles( RECORDING[ REPLAYING_POS ].eyes )
		pl:SetVelocity( RECORDING[ REPLAYING_POS ].velocity - pl:GetVelocity() )
		--pl:SetViewAngles( RECORDING[ REPLAYING_POS ].eyes )
	end
end )]]