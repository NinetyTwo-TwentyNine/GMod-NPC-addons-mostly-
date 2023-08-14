AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

SWEP.Weight				= 30		// Decides whether we should switch from/to this
SWEP.AutoSwitchTo			= true		// Auto switch to  we pick it up
SWEP.AutoSwitchFrom			= true		// Auto switch from  you pick up a better weapon

function SWEP:Initialize()
	if !IsValid(self.Owner) then self:Remove() return end

	self:SetWeaponHoldType(self.HoldType)
	self.NextFireTime = CurTime()
	if self.Owner:GetClass() == "npc_citizen" then
	self.Weapon.Owner:Fire( "DisableWeaponPickup" )
	end
	if self.Owner:GetClass() == "npc_combine_s" then
	self:Proficiency()
	hook.Add( "Think", self, self.onThink )
	end
end

function SWEP:onThink()
	self:NextFire()
end

function SWEP:NextFire()
	if !self:IsValid() or !self.Owner:IsValid() then return; end

	if IsValid(self.Owner:GetEnemy()) then
		if self.Owner:GetEnemy():IsPlayer() then
			if IsValid(self.Owner:GetEnemy():GetVehicle()) || IsValid(self.Owner:GetEnemy():lfsGetPlane()) then
				self.Owner:AddEntityRelationship(self.Owner:GetEnemy(), D_HT, 99)
			else
				self.Owner:AddEntityRelationship(self.Owner:GetEnemy(), D_FR, 99)
			end
		elseif self.Owner:GetEnemy():IsNPC() then
			if self.Owner:GetEnemy():GetClass() == "npc_vehicledriver" || self.Owner:GetEnemy():GetClass() == "npc_apcdriver" then
				self.Owner:AddEntityRelationship(self.Owner:GetEnemy(), D_HT, 99)
			elseif self.Owner:GetEnemy():GetHullType() == HULL_HUMAN || self.Owner:GetEnemy():GetHullType() == HULL_WIDE_HUMAN then
				self.Owner:AddEntityRelationship(self.Owner:GetEnemy(), D_FR, 99)
			end
		end
	end

	if self.Owner:IsCurrentSchedule(43) || self.Owner:IsCurrentSchedule(44) then
		self:NPCPrimaryAttack()
			hook.Remove("Think", self)
			
	timer.Simple(2.0, function()
		if !self:IsValid() or !self.Owner:IsValid() then return; end
		hook.Add("Think", self, self.NextFire)
		end)
	end
end

function SWEP:Proficiency()
timer.Simple(0.1, function()
	if !self:IsValid() or !self.Owner:IsValid() then return; end
//self.Owner:CapabilitiesRemove(64)
self.Owner:CapabilitiesAdd(1073741824)
self.Owner:SetCurrentWeaponProficiency(4)
	end)
end

AccessorFunc( SWEP, "fNPCMinBurst",                 "NPCMinBurst" )
AccessorFunc( SWEP, "fNPCMaxBurst",                 "NPCMaxBurst" )
AccessorFunc( SWEP, "fNPCFireRate",                 "NPCFireRate" )
AccessorFunc( SWEP, "fNPCMinRestTime",         "NPCMinRest" )
AccessorFunc( SWEP, "fNPCMaxRestTime",         "NPCMaxRest" )

function SWEP:OnDrop()
	self:Remove()
end