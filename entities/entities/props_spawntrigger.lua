AddCSLuaFile()
DEFINE_BASECLASS( "base_entity" )

ENT.PrintName = "Spawn Trigger"
ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.Editable = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT  -- Needed for DrawTranslucent()

function ENT:SetupDataTables()
end

function ENT:KeyValue(key, value)
    if key == "mins" then
        self.Mins = util.StringToType(value, "Vector")
    elseif key == "maxs" then
        self.Maxs = util.StringToType(value, "Vector")
    end
end

function ENT:Initialize()

	if ( SERVER ) then
		local mins = self.Mins
		local maxs = self.Maxs

			-- Convert to local space relative to the entity
		local localVec1 = self:WorldToLocal(mins)
		local localVec2 = self:WorldToLocal(maxs)

		-- Calculate mins and maxs from those local vectors
		mins = Vector(
			math.min(localVec1.x, localVec2.x),
			math.min(localVec1.y, localVec2.y),
			math.min(localVec1.z, localVec2.z)
		)

		maxs = Vector(
			math.max(localVec1.x, localVec2.x),
			math.max(localVec1.y, localVec2.y),
			math.max(localVec1.z, localVec2.z)
		)

		self:SetSolid( SOLID_BBOX )
		self:SetTrigger( true )
		self:PhysicsInitBox(mins, maxs)
		self:SetCollisionBounds(mins, maxs)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetNotSolid( true )
		self:DrawShadow(false)
	end

end

function ENT:StartTouch( ent )

		-- can we jsut do PhysicsCollide?
		-- Forward to sv_antinoob to handle logic.
	hook.Run("props_spawntrigger_starttouch", self, ent)
end

function ENT:GetOverlayText()

end

function ENT:OnTakeDamage( dmginfo )


end

function ENT:Draw()
end

function ENT:DrawTranslucent( flags )

		-- Code not needed as we draw it through spawnprotect.lua gmod_tool.
		-- We'll keep this here in case we ever need to debug though
	--[[local mins, maxs = self:GetCollisionBounds()

	render.SetColorMaterial()
	render.DrawWireframeBox(self:GetPos(), self:GetAngles(), mins, maxs, Color(0, 255, 0), true)]]

end

if SERVER then
	--[[concommand.Add("test_spawntrigger", function( pl )
		local trigger = ents.Create( "props_spawntrigger")
		trigger:SetPos( pl:GetEyeTrace().HitPos )
		trigger:SetKeyValue("maxs", "70 70 70")
		trigger:Spawn()
	end )]]
end
