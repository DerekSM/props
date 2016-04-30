--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Handles anti-spawn blocking/killing.
			Removes frozen props in spawn
			Removes huge props in spawn
			Gives people babygod (can't be killed for a certain amount of time)
			
		Also adds configuration options so there's really no reason to remove this module
		
		Also features a whitelist, people in the whitelist
			Can circumvent the anti frozen props, huge props, and people with babygod.
]]--

	
--[[

*

* Configurables. These can all be modified in-game.

* Don't change unless you want to break something.

*

--]]

AddConfigItem( "babygod",
	{
	Name = "Babygod",
	default = true,
	Category = "Player Spawning",
	type = "boolean",
	desc = "When players spawn they will have temp godmode.",
	}
)

AddConfigItem( "babygod_time",
	{
	Name = "Babygod Time",
	Category = "Player Spawning",
	default = 1.55,
	type = "integer",
	desc = "Spawned players have godmode for this long.",
	}
)

AddConfigItem( "spawnprotection", 
	{
	Name = "Spawn Protection",
	Category = "Player Spawning",
	default = true,
	type = "boolean",
	desc = "Toggle anti-spawnblock.",
	}
)

	-- How many units from spawn to check for
local detectionRadius = 305

	-- whitelist
local whitelist =
{
		-- Shinycow
	"STEAM_0:0:29257121",
}



--[[

*

* Rest of code should be untouched from here.

* Don't change unless you want to break something.

*

--]]




if CLIENT then return end

	-- holds table of player spawns
local props_playerSpawns = {}

local function AddPlayerSpawn()
	for k,v in pairs( ents.GetAll() ) do
		
		if v:GetClass() == "info_player_start" then
			props_playerSpawns[ #props_playerSpawns + 1 ] = v
		end
		
	end
	
	if game.GetMap() == "gm_construct" then detectionRadius = 240 end
end
hook.Add( "InitPostEntity", "props_AddSpawns", AddPlayerSpawn )
hook.Add( "OnReloaded", "props_AddSpawns", AddPlayerSpawn )

hook.Add( "PlayerInitialSpawn", "props_RegisterWhitelist", function( pl )
		-- don't bitch that I'm using table.HasValue
		-- It's easier to modify the whitelist
	if table.HasValue( whitelist, pl:SteamID() ) then
			
		pl.propsWhitelisted = true
	
	end
end )

timer.Create( "props_antiNoob", 1.36, 0, function()
	if not PROPKILL.Config[ "spawnprotection" ].default then return end
	if PROPKILL.Battling then return end
	
	for i=1,#props_playerSpawns do
		
		for k,v in pairs( ents.GetAll() ) do
			if v.beingRemoved or not v.Owner or not v.Owner:IsPlayer() or v.Owner.propsWhitelisted then continue end
			
			if v:GetPos():Distance( props_playerSpawns[ i ]:GetPos() ) <= detectionRadius then
				
				if v.GetPhysicsObject and IsValid( v:GetPhysicsObject() ) then
					local phys = v:GetPhysicsObject()
					
					--print( v:GetClass() )
					
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
		end
		
	end
end )


--[[hook.Add( "Think", "props_babyGod", function()
	for k,v in pairs( player.GetAll() ) do
		if not v:Alive() then continue end
		
		if not v.leftSpawn then
			if not v.spawnPos then continue end
			
			if v.spawnPos:Distance( v:GetPos() ) >= 275 then
				
				v.leftSpawn = true
				if PROPKILL.Config[ "babygod_time" ].default < 1 then
					v.babyGod = false
				else
					timer.Create( "props_babyGod" .. v:UserID(), PROPKILL.Config[ "babygod_time" ].default, 1, function()
						if not IsValid( v ) then return end
						
						v.babyGod = false
					end )
				end
			
			end
		end
	end
end )]]
hook.Add( "PlayerTick", "props_babyGod", function( pl, mv )
	if not pl:Alive() then return end
		
	if not pl.leftSpawn then
		if not pl.spawnPos then return end
			
		if pl.spawnPos:Distance( pl:GetPos() ) >= 275 then
				
			pl.leftSpawn = true
			if PROPKILL.Config[ "babygod_time" ].default < 1 then
				pl.babyGod = false
			else
				timer.Create( "props_babyGod" .. pl:UserID(), PROPKILL.Config[ "babygod_time" ].default, 1, function()
					if not IsValid( pl ) then return end
						
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