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
oldcleanupAdd = oldcleanupAdd or cleanup.Add
function cleanup.Add( pl, num, ent )
	if not IsValid(pl) or not IsValid(ent) then return end

	ent.Owner = pl
	pl.Props = (pl.Props or 0) + 1
	pl.Entities = pl.Entities or {}
	pl.Entities[ #pl.Entities + 1 ] = ent
	
	if ent:GetClass() != "prop_physics" then
		PROPKILL.Statistics[ "otherspawns" ] = PROPKILL.Statistics[ "otherspawns" ] or 0
		PROPKILL.Statistics[ "otherspawns" ] = PROPKILL.Statistics[ "otherspawns" ] + 1
	end
			
	return oldcleanupAdd( pl, num, ent )
end