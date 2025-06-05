if not props_antinoobdetectionRadius then print( "SV_ANTINOOB NOT LOADING." ) return end

-- check an even bigger distance for props staying in an area for a long period of time, also increase big props to be blacklisted.
local ents = ents

	-- holds table of player spawns
local props_playerSpawns = {}
local props_playerSpawnsCount = 0

local function AddPlayerSpawn()
	for k,v in next, ents.FindByClass("info_player_start") do
		props_playerSpawns[ #props_playerSpawns + 1 ] = v:GetPos()
		props_playerSpawnsCount = props_playerSpawnsCount + 1
	end

	if game.GetMap() == "gm_construct" then props_antinoobdetectionRadius = 238^2 end
		-- alternatively, add another player spawn point with LUA .. near the exit ?
	if game.GetMap() == "rp_downtown_v2_propkill_v1b" then props_antinoobdetectionRadius = 359^2 end
end
hook.Add( "InitPostEntity", "props_AddSpawns", AddPlayerSpawn )
hook.Add( "OnReloaded", "props_AddSpawns", AddPlayerSpawn )

hook.Add( "PlayerInitialSpawn", "props_RegisterWhitelist", function( pl )
		-- found in sh_antinoob.lua
	if table.HasValue( props_antinoobwhitelist, pl:SteamID() ) then

		pl.propsWhitelisted = true

	end
end )


hook.Add("props_spawntrigger_starttouch", "props_antiNoob", function( trigger, ent )
	if not PROPKILL.Config[ "spawnprotection" ].default then return end
	if PROPKILL.Battling then return end

	if ent.beingRemoved or not ent.Owner or not ent.Owner:IsPlayer()
	or (ent:IsWeapon() and IsValid( ent:GetOwner() )) or ent.Owner.propsWhitelisted then
		return
	end

	if ent.GetPhysicsObject and IsValid( ent:GetPhysicsObject() ) then
		local phys = ent:GetPhysicsObject()

			-- frozen
		if not phys:IsMotionEnabled() then
			ent.beingRemoved = true
			ent.Owner:Notify( NOTIFY_ERROR, 4, "Frozen objects aren't allowed in this area" )
			ent:Remove()
		else
			if not ent.Owner.babyGod then
				ent.beingRemoved = true
				ent.Owner:Notify( NOTIFY_ERROR, 4, "Prop was removed for entering spawn" )
				ent:Remove()
			else
				if phys:GetVolume() > 4*10^5 then
					ent.beingRemoved = true
					ent.Owner:Notify( NOTIFY_ERROR, 4, "Prop was removed due to being huge" )
					ent:Remove()
				end
			end
		end
	end
end )


	-- We can afford to lower the time between checks because we optimized this code.
timer.Create( "props_antiNoob", 0.41, 0, function()
	if not PROPKILL.Config[ "spawnprotection" ].default then return end
	if PROPKILL.Battling then return end

		-- An admin created a spawn protection area! Use this code instead!
	if AntinoobSpawnProtectionAreas and #AntinoobSpawnProtectionAreas > 0 then

		for i=1,#AntinoobSpawnProtectionAreas do
			local ProtectionAreaValues = AntinoobSpawnProtectionAreas[i]

				-- Extended spawn area. Won't immediately remove but if props linger they will be removed.
			local Center = (ProtectionAreaValues.startpos + ProtectionAreaValues.endpos) / 2
			local Newmin = Center + (ProtectionAreaValues.startpos - Center) * 1.3
			local Newmax = Center + (ProtectionAreaValues.endpos - Center) * 1.3
			for i2=1,#ents.FindInBox( Newmin, Newmax ) do
				local v = ents.FindInBox( Newmin, Newmax )[i2]

				if v.beingRemoved or not v.Owner or not v.Owner:IsPlayer()
				or (v:IsWeapon() and IsValid( v:GetOwner() )) or v.Owner.propsWhitelisted then
					continue
				end

				if v.GetPhysicsObject and IsValid( v:GetPhysicsObject() ) then
					v.RemovalCount = (v.RemovalCount or 0) + 1

					if v.RemovalCount >= 7 then
						v.beingRemoved = true
						v.Owner:Notify( NOTIFY_ERROR, 4, "Props are not allowed to stay in the spawn area" )
						v:Remove()
					end
				end
			end
		end

		-- NO Admin-created spawn protection areas. Use defaults!
	else


		for i=1,props_playerSpawnsCount do

				-- https://wiki.facepunch.com/gmod/ents.FindByClass
				-- ents.FindByClass / ents.Interator may be faster than ents.GetAll. Alternatively use ents.FindInBox
				-- A lazier way may even be ents.FindInPVS
				-- Profile this code!!!
				-- Update: After profiling, out of the three options (.GetAll, Iterator, and FindInPVS), FindInPVS wins.
				-- In fact, according to my shoddy profiling we are >2x faster now.
			for k,v in next, ents.FindInPVS(props_playerSpawns[i]) do
				if v.beingRemoved or not v.Owner or not v.Owner:IsPlayer() or (v:IsWeapon() and IsValid( v:GetOwner() )) or v.Owner.propsWhitelisted then continue end

				local EntDistanceFromSpawn = v:GetPos():DistToSqr( props_playerSpawns[ i ] )
				if EntDistanceFromSpawn <= props_antinoobdetectionRadius then

					if v.GetPhysicsObject and IsValid( v:GetPhysicsObject() ) then
						local phys = v:GetPhysicsObject()

							-- frozen
						if not phys:IsMotionEnabled() then
							v.beingRemoved = true
							v.Owner:Notify( NOTIFY_ERROR, 4, "Frozen objects aren't allowed in this area" )
							v:Remove()
						else
							if not v.Owner.babyGod then
								v.beingRemoved = true
								v.Owner:Notify( NOTIFY_ERROR, 4, "Prop was removed for entering spawn" )
								v:Remove()
							else
								if phys:GetVolume() > 4*10^5 then
									v.beingRemoved = true
									v.Owner:Notify( NOTIFY_ERROR, 4, "Prop was removed due to being huge" )
									v:Remove()
								end
							end
						end
					end
				end

				if EntDistanceFromSpawn <= ( (props_antinoobdetectionRadius + 1) * 2 ) then
					if v.GetPhysicsObject and IsValid( v:GetPhysicsObject() ) then
						v.RemovalCount = (v.RemovalCount or 0) + 1

						if v.RemovalCount >= 3*props_playerSpawnsCount then
							v.beingRemoved = true
							v.Owner:Notify( NOTIFY_ERROR, 4, "Props are not allowed to stay in the spawn area" )
							v:Remove()
						end
					end
				end

			end
		end
	end
end )

hook.Add( "PlayerTick", "props_babyGod", function( pl, mv )
	if not pl:Alive() then return end

	if not pl.leftSpawn then
		if not pl.spawnPos then return end

		if pl.spawnPos:Distance( pl:GetPos() ) >= 145 then

			pl.leftSpawn = true
			if PROPKILL.Config[ "babygod_time" ].default < 1 then
				pl.babyGod = false
			else
				timer.CreatePlayer( pl, "props_babyGod", PROPKILL.Config[ "babygod_time" ].default, 1, function()
					pl.babyGod = false
				end )
			end

		end
	end
end )

hook.Add( "PlayerSpawn", "props_babyGod", function( pl )
	if not PROPKILL.Config[ "babygod" ].default then
		pl.babyGod = false
		return
	end

	pl.babyGod = true
	pl.leftSpawn = false
	pl.spawnPos = pl:GetPos()
end )

hook.Add( "PlayerShouldTakeDamage", "props_babyGod", function( pl, attacker, inflictor )
	if (not IsValid( attacker ) and attacker != Entity( 0 )) or ( not pl:IsPlayer() and pl.IsBot and not pl:IsBot() ) then
		print( "sh_antinoob.lua" )
		return false
	end

	if PROPKILL.Battling then return end

	if not PROPKILL.Config[ "babygod" ].default then
		return true
	end

	if attacker.Owner and attacker.Owner:IsPlayer() then

		if attacker.Owner.propsWhitelisted then
			return true
		end

		if pl:Team() == attacker.Owner:Team() and pl:Team() != TEAM_DEATHMATCH and pl != attacker.Owner then
			return GetConVarNumber( "mp_friendlyfire" ) > 0
		end

		if pl.babyGod then
			return false
		end
		if attacker.Owner.babyGod then
			return false
		end

	elseif attacker == Entity(0) then

		--return not pl.babyGod
		local prop_owner = pl:GetNearestProp()
		if IsValid( prop_owner ) and prop_owner.Owner and prop_owner.Owner:IsPlayer() then

			prop_owner = prop_owner.Owner

			if prop_owner.propsWhitelisted then
				return true
			end

			if prop_owner:Team() == pl:Team() and pl:Team() != TEAM_DEATHMATCH then
				return GetConVarNumber( "mp_friendlyfire" ) > 0
			end

			if pl.babyGod then
				return false
			end

			if prop_owner.babyGod then
				return false
			end

		else

			return not pl.babyGod

		end

	end

	return true
end )
