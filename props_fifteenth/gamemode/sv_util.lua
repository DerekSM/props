--[[
				  _________.__    .__                                  
				 /   _____/|  |__ |__| ____ ___.__. ____  ______  _  __
				 \_____  \ |  |  \|  |/    <   |  |/ ___\/  _ \ \/ \/ /
				 /        \|   Y  \  |   |  \___  \  \__(  <_> )     / 
				/_______  /|___|  /__|___|  / ____|\___  >____/ \/\_/  
						\/      \/        \/\/         \/              

		Serverside utilities
]]--

--[[

*

* Cleans up entities not wanted in a propkilling environment.

*

--]]
function util.CleanUpMap( b_Props )
	for k,v in next, ents.GetAll() do
	
			-- sounds
		if v:GetClass() == "env_soundscape" or v:GetClass() == "ambient_generic"
		or string.find( tostring( v ) , "scene" )
		or string.find( tostring( v ), "illusion" ) then
			v:Remove()
		end
		
			-- windows
		if v:GetClass() == "func_breakable_surf" then
			v:Remove()
		end
		
			-- props created by map
		if v:GetClass() == "prop_static" then
			v:Remove()
		end
		
	end
	
	if b_Props then
		
		for k,v in next, ents.GetAll() do
			
			if v:GetClass() == "prop_physics" then
				v:Remove()
			end
		
		end
	
	end
end

--[[

*

* Registers all entities that players spawn to them.

*

--]]
	-- 5 million
local autoremove = 5000000
	-- 730k
local autotrigger = 730000

local volumewhitelist = {}
volumewhitelist[ "models/props_combine/breen_tube.mdl" ] = true

oldcleanupAdd = oldcleanupAdd or cleanup.Add
function cleanup.Add( pl, num, ent )
	if not IsValid(pl) or not IsValid(ent) then return end
	
	if IsValid( ent:GetPhysicsObject() ) then
		local physobj = ent:GetPhysicsObject()

		if physobj:GetVolume() >= autoremove and not volumewhitelist[ string.lower( ent:GetModel() ) ] then
			pl:Notify( 1, 4, "Prop removed: It was too large" )
			--pl:ChatPrint( physobj:GetVolume() )
			PROPKILL.HugeProps[ string.lower( ent:GetModel() ) ] = true
			ent:Remove()
			return
		end
	end
	
	--print( pl:Nick() .. " spawned a " .. ent:GetClass() .. " (" .. ent:GetModel() .. ")" )
	ent.Owner = pl
	if ent:GetClass() == "prop_physics" then
		pl.Props = (pl.Props or 0) + 1
	end
	pl.Entities = pl.Entities or {}
	pl.Entities[ #pl.Entities + 1 ] = ent
	
	if ent:GetClass() != "prop_physics" then
		PROPKILL.Statistics[ "otherspawns" ] = PROPKILL.Statistics[ "otherspawns" ] or 0
		PROPKILL.Statistics[ "otherspawns" ] = PROPKILL.Statistics[ "otherspawns" ] + 1
	end
			
	return oldcleanupAdd( pl, num, ent )
end