AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')
include("ai_translations.lua")

SWEP.Weight=5
SWEP.AutoSwitchTo=false
SWEP.AutoSwitchFrom=false

/*---------------------------------------------------------
   Name: NPCShoot_Secondary
   Desc: NPC tried to fire secondary attack
---------------------------------------------------------*/
function SWEP:NPCShoot_Secondary(ShootPos,ShootDir)
	//the fuck are you doing, son?
end

/*---------------------------------------------------------
   Name: NPCShoot_Primary
   Desc: NPC tried to fire primary attack
---------------------------------------------------------*/
function SWEP:NPCShoot_Primary(ShootPos,ShootDir)
	if (self.NextFireTime <= CurTime()) then
		self.FiredRocket = true

		self:EmitSound("weapons/rpg/rocketfire1.wav")
		local enemy = self.Owner:GetEnemy()
		local rocket = ents.Create("rpg_missile")
		rocket:SetPos(ShootPos+ShootDir)
		rocket:SetAngles(ShootDir:Angle())
		rocket:SetOwner(self.Owner)
		rocket:Spawn()
		rocket:AddFlags(FL_NOTARGET)
		rocket:CallOnRemove("The launcher no longer has an active rocket", function(ent)
			if !IsValid(self) then return end
			self.FiredRocket = false
		end)
		rocket:SetSaveValue( "m_flDamage", GetConVarNumber("sk_npc_dmg_rpg_round") )
		rocket:Activate()

		timer.Simple(0.33, function()
			if !IsValid(rocket) then return end

			rocket.DirVector = rocket:GetAngles():Forward()
			if IsValid(self) then
				if IsValid(self.Owner) && IsValid(enemy) then
					local FT_Angle = (enemy:BodyTarget(rocket:GetPos()) - rocket:GetPos()):Angle()
					rocket.DirVector = FT_Angle:Forward() + Vector(math.Rand(-0.015, 0.015),math.Rand(-0.015, 0.015),math.Rand(-0.015, 0.015))*(5-self.Owner:GetCurrentWeaponProficiency())
					rocket:SetAngles(rocket.DirVector:Angle())
				end
			end
			rocket:SetVelocity(rocket.DirVector * 3000)
		end)

		self.NextFireTime = CurTime() + 3
		self:SetNextPrimaryFire( self.NextFireTime )
		self.Owner:StopMoving()

		if self.Owner:GetSequenceInfo(self.Owner:LookupSequence("shoot_rpg")) != nil then
			self.Owner:RestartGesture(self.Owner:GetSequenceInfo(self.Owner:LookupSequence("shoot_rpg")).activity)
		end
	end
end

function SWEP:FireAnimationEvent( pos, ang, event, options )
	if (self.NextFireTime > CurTime() || self.FiredRocket) then return true end
end


function SWEP:OnDrop()
	self:SetKeyValue("spawnflags", tostring(bit.bor(tonumber(self:GetKeyValues()["spawnflags"]), 2)))
end