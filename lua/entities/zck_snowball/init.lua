AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local PlayerPVPState = {}
hook.Add( "PlayerSpawn", "SnowballPvPCheck", function(Ply)
	PlayerPVPState[Ply:EntIndex()] = tobool(Ply:GetInfoNum("snowball_allow_pvp_on_me", 1))
end )

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:PhysicsCollide(data, phys)
	if IsValid(data.HitEntity) and data.HitEntity:IsPlayer() and data.HitEntity:Alive() then
		-- Check if player is in pvp mode
		if not PlayerPVPState[data.HitEntity:EntIndex()] then self:Explode() return end
		if not PlayerPVPState[self.Owner:EntIndex()] then self:Explode() return end

		data.HitEntity:TakeDamage(zck.config.Swep.damage, self.Owner, self)
	end

	self:Explode()
end

function ENT:Explode()
	if vFireInstalled then
		for k, ent in pairs(ents.FindInSphere(self:GetPos(),100)) do
			ent:Extinguish()
		end
	end
	SafeRemoveEntityDelayed(self, 0.1)
end
