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

	if !self.Owner:GetEnemy() then return end
	local att = self.Owner:GetShootPos() + self.Owner:EyeAngles():Right() * 10 + self.Owner:EyeAngles():Forward() * 10
	local posTgt = self.Owner:GetEnemy():BodyTarget(att)
	local angAcc = (posTgt-att):Angle()
	local dirVec = angAcc:Forward() + Vector(0,math.Rand(-self.Primary.Spread,self.Primary.Spread),math.Rand(-self.Primary.Spread,self.Primary.Spread))*(5-self.Owner:GetCurrentWeaponProficiency())

	local secondary_check = util.TraceLine({
		start = att,
		endpos = att + angAcc:Forward()*32768,
		filter = function(hit) return (hit != self) end
	})
	local secondary_check_dist = secondary_check.StartPos:Distance(secondary_check.HitPos)
	if secondary_check_dist < 100 then 
		self.Owner:NavSetRandomGoal( 100-secondary_check_dist, -angAcc:Forward() )
		self.Owner:StartEngineTask( 48, 0 )
		return end


	self.Weapon:EmitSound(self.Primary.Sound)
		local soundname = sound.GetProperties(self.Primary.Sound).sound
		if istable(soundname) then soundname = table.Random(soundname) end
		sound.Play(soundname,self:GetPos(),150,math.random(75,80),0.4)
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
		

		local ent = ents.Create( "lunasflightschool_missile" )
		ent:SetPos( att )
		ent:SetAngles( dirVec:Angle() )
		ent:SetOwner( self.Owner )
		ent.Attacker = self.Owner
		ent:Spawn()
		ent:Activate()
	
		ent:SetAttacker( self.Owner )
		ent:SetInflictor( self.Owner:GetActiveWeapon() )
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
end