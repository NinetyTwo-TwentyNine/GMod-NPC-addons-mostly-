SWEP.Base = "base_npc_m9k"

if GetConVar("M9KDefaultClip") == nil then
	print("M9KDefaultClip is missing! You may have hit the lua limit!")
else
	if GetConVar("M9KDefaultClip"):GetInt() != -1 then
		SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize * GetConVar("M9KDefaultClip"):GetInt()
	end
end

if GetConVar("M9KUniqueSlots") != nil then
	if not (GetConVar("M9KUniqueSlots"):GetBool()) then 
		SWEP.SlotPos = 2
	end
end

function SWEP:PrimaryAttack()
	if CurTime() < self.NextFireTime then return end 
	self.NextFireTime = CurTime() + 1 / (self.Primary.RPM / 60)

	if self:Clip1() <= 0 then self:NpcReload()
	return end 
		self.Weapon:EmitSound(self.Primary.Sound)
		if !self.Silenced then
			local soundname = sound.GetProperties(self.Primary.Sound).sound
			if istable(soundname) then soundname = table.Random(soundname) end
			sound.Play(soundname,self:GetPos(),120,math.random(85,90),0.4)
		end
		local fx 		= EffectData()
		fx:SetEntity(self.Weapon)
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:GetAimVector())
		fx:SetAttachment(self.MuzzleAttachment)
		if GetConVar("M9KGasEffect") != nil then
			if GetConVar("M9KGasEffect"):GetBool() then 
				util.Effect("m9k_rg_muzzle_rifle",fx)
			end
				end
		self:TakePrimaryAmmo( 1 )
		self:ShootBulletInformation()
end

function SWEP:Reload()

end

function SWEP:NpcReload()
	if !self:IsValid() or !self.Owner:IsValid() then return; end
	self.Owner:SetSchedule(SCHED_RELOAD)

end


function SWEP:NPCPrimaryAttack()
	if (!self:IsValid()) or (!self.Owner:IsValid()) then return;end
		self:PrimaryAttack()

	if self.Owner:GetClass() == "npc_combine_s" then
		for i = 1,(self.Primary.ShortBurst or 2) do
			timer.Simple(1 / (self.Primary.RPM / 60) * i, function()
			if (!self:IsValid()) or (!self.Owner:IsValid()) then return;end
			if !(self.Owner:IsCurrentSchedule(43) || self.Owner:IsCurrentSchedule(44)) then return; end 
				self:PrimaryAttack()
				end)
				end
	else
		for i = 1,(self.Primary.LongBurst or 3) do
			timer.Simple(1 / (self.Primary.RPM / 60) * i, function()
			if (!self:IsValid()) or (!self.Owner:IsValid()) then return;end
			if !(self.Owner:IsCurrentSchedule(43) || self.Owner:IsCurrentSchedule(44)) then return; end 
				self:PrimaryAttack()
				end)
				end
	end
end