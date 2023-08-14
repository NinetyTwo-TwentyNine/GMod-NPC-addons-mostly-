local PainMulti = 1
 
if GetConVar("M9KDamageMultiplier") == nil then
		PainMulti = 1
		print("M9KDamageMultiplier is missing! You may have hit the lua limit! Reverting multiplier to 1.")
else
		PainMulti = GetConVar("M9KDamageMultiplier"):GetFloat()
		if PainMulti < 0 then
				PainMulti = PainMulti * -1
				print("Your damage multiplier was in the negatives. It has been reverted to a positive number. Your damage multiplier is now "..PainMulti)
		end
end

function NewM9KDamageMultiplier(cvar, previous, new)
		print("multiplier has been changed ")
		if GetConVar("M9KDamageMultiplier") == nil then
				PainMulti = 1
				print("M9KDamageMultiplier is missing! You may have hit the lua limit! Reverting multiplier to 1, you will notice no changes.")
		else
				PainMulti = GetConVar("M9KDamageMultiplier"):GetFloat()
				if PainMulti < 0 then
						PainMulti = PainMulti * -1
						print("Your damage multiplier was in the negatives. It has been reverted to a positive number. Your damage multiplier is now "..PainMulti)
				end
		end
end
cvars.AddChangeCallback("M9KDamageMultiplier", NewM9KDamageMultiplier)
 
/*---------------------------------------------------------
   Name: SWEP:ShootBulletInformation()
   Desc: This func add the damage, the recoil, the number of shots and the cone on the bullet.
-----------------------------------------------------*/
function SWEP:ShootBulletInformation()
 
		local CurrentDamage
		local CurrentCone
		local CurrentDirection
		local basedamage
	   
		if self.Owner:GetActivity() == 11 then
		CurrentCone = self.Primary.Spread
		else
		CurrentCone = self.Primary.IronAccuracy
		end
		CurrentCone = CurrentCone * (5-self.Owner:GetCurrentWeaponProficiency())

		local damagedice = math.Rand(.85,1.3)
		basedamage = PainMulti * self.Primary.Damage
		CurrentDamage = basedamage * damagedice

		CurrentDirection = self.Owner:GetAimVector()
		if self.Owner:GetEnemy() != nil then
			local att = self:GetAttachment(self.MuzzleAttachment)
			local posTgt = self.Owner:GetEnemy():LocalToWorld(self.Owner:GetEnemy():OBBCenter()) 
			local angAcc = (posTgt -att.Pos):Angle()
			CurrentDirection = Angle(math.ApproachAngle(att.Ang.p,angAcc.p,45),math.ApproachAngle(att.Ang.y,angAcc.y,35),0):Forward()
		end
	   
		if IsValid(self) then
			if IsValid(self.Weapon) then
				if IsValid(self.Owner) then
				self:ShootBullet(CurrentDamage, self.Primary.NumShots, CurrentCone, CurrentDirection)
				end
			end
		end
	   
end
 
/*---------------------------------------------------------
   Name: SWEP:ShootBullet()
   Desc: A convenience func to shoot bullets.
-----------------------------------------------------*/
local TracerName = "Tracer"
 
function SWEP:ShootBullet(damage, num_bullets, aimcone, bullet_dir)
 
		num_bullets             = num_bullets or 1
		aimcone                         = aimcone or 0
 
		self:ShootEffects()
 
		if self.Tracer == 1 then
				TracerName = "Ar2Tracer"
		elseif self.Tracer == 2 then
				TracerName = "AirboatGunHeavyTracer"
		else
				TracerName = "Tracer"
		end	
	   
		local bullet = {}
				bullet.Num              = num_bullets
				bullet.Src              = self.Owner:GetShootPos()                      -- Source
				bullet.Dir              = bullet_dir                     -- Dir of bullet
				bullet.Spread   = Vector(aimcone, aimcone, 0)                   -- Aim Cone
				bullet.Tracer   = 3                                                     -- Show a tracer on every x bullets
				bullet.TracerName = TracerName
				bullet.Force    = damage * 0.25                                 -- Amount of force to give to phys objects
				bullet.Damage   = damage
				bullet.Callback = function(attacker, tracedata, dmginfo)	
										dmginfo:SetDamageType( DMG_BULLET )   
										return self:RicochetCallback(0, attacker, tracedata, dmginfo)
								  end
		if IsValid(self) then
			if IsValid(self.Weapon) then
				if IsValid(self.Owner) then
				self.Owner:FireBullets(bullet)
				end
			end
		end
 
end
 
/*---------------------------------------------------------
   Name: SWEP:RicochetCallback()
-----------------------------------------------------*/
 
function SWEP:RicochetCallback(bouncenum, attacker, tr, dmginfo)
	   
		if not IsFirstTimePredicted() then
		return {damage = false, effects = false}
		end
	   
		local PenetrationChecker = false
	   
		if GetConVar("M9KDisablePenetration") == nil then
				PenetrationChecker = false
		else
				PenetrationChecker = GetConVar("M9KDisablePenetration"):GetBool()
		end
	   
		if PenetrationChecker then return {damage = true, effects = DoDefaultEffect} end
 
		bulletmiss = {}
				bulletmiss[1]=Sound("weapons/fx/nearmiss/bulletLtoR03.wav")
				bulletmiss[2]=Sound("weapons/fx/nearmiss/bulletLtoR04.wav")
				bulletmiss[3]=Sound("weapons/fx/nearmiss/bulletLtoR06.wav")
				bulletmiss[4]=Sound("weapons/fx/nearmiss/bulletLtoR07.wav")
				bulletmiss[5]=Sound("weapons/fx/nearmiss/bulletLtoR09.wav")
				bulletmiss[6]=Sound("weapons/fx/nearmiss/bulletLtoR10.wav")
				bulletmiss[7]=Sound("weapons/fx/nearmiss/bulletLtoR13.wav")
				bulletmiss[8]=Sound("weapons/fx/nearmiss/bulletLtoR14.wav")
			   
		local DoDefaultEffect = true
		if (tr.HitSky) then return end
	   
		// -- Can we go through whatever we hit?
		if (self.Penetration) and (self:BulletPenetrate(bouncenum, attacker, tr, dmginfo)) then
				return {damage = true, effects = DoDefaultEffect}
		end
	   
		// -- Your screen will shake and you'll hear the savage hiss of an approaching bullet which passing if someone is shooting at you.
		if (tr.MatType != MAT_METAL) then
				if (SERVER) then
						util.ScreenShake(tr.HitPos, 5, 0.1, 0.5, 64)
						sound.Play(table.Random(bulletmiss), tr.HitPos, 75, math.random(75,150), 1)
				end
 
				if self.Tracer == 0 or self.Tracer == 1 or self.Tracer == 2 then
						local effectdata = EffectData()
								effectdata:SetOrigin(tr.HitPos)
								effectdata:SetNormal(tr.HitNormal)
								effectdata:SetScale(20)
						util.Effect("AR2Impact", effectdata)
				elseif self.Tracer == 3 then
						local effectdata = EffectData()
								effectdata:SetOrigin(tr.HitPos)
								effectdata:SetNormal(tr.HitNormal)
								effectdata:SetScale(20)
						util.Effect("StunstickImpact", effectdata)
				end
 
				return
		end
 
		if (self.Ricochet == false) then return {damage = true, effects = DoDefaultEffect} end
	   
		if self.Primary.Ammo == "SniperPenetratedRound" then -- .50 Ammo
				self.MaxRicochet = 12
		elseif self.Primary.Ammo == "pistol" then -- pistols
				self.MaxRicochet = 2
		elseif self.Primary.Ammo == "357" then -- revolvers with big ass bullets
				self.MaxRicochet = 4
		elseif self.Primary.Ammo == "smg1" then -- smgs
				self.MaxRicochet = 5
		elseif self.Primary.Ammo == "ar2" then -- assault rifles
				self.MaxRicochet = 8
		elseif self.Primary.Ammo == "buckshot" then -- shotguns
				self.MaxRicochet = 1
		elseif self.Primary.Ammo == "slam" then -- secondary shotguns
				self.MaxRicochet = 1
		elseif self.Primary.Ammo ==     "AirboatGun" then -- metal piercing shotgun pellet
				self.MaxRicochet = 8
		end
	   
		if (bouncenum > self.MaxRicochet) then return end
	   
		// -- Bounce vector
		local trace = {}
		trace.start = tr.HitPos
		trace.endpos = trace.start + (tr.HitNormal * 16384)
 
		local trace = util.TraceLine(trace)
 
		local DotProduct = tr.HitNormal:Dot(tr.Normal * -1)
	   
		local ricochetbullet = {}
				ricochetbullet.Num              = 1
				ricochetbullet.Src              = tr.HitPos + (tr.HitNormal * 5)
				ricochetbullet.Dir              = ((2 * tr.HitNormal * DotProduct) + tr.Normal) + (VectorRand() * 0.05)
				ricochetbullet.Spread   = Vector(0, 0, 0)
				ricochetbullet.Tracer   = 1
				ricochetbullet.TracerName       = "m9k_effect_mad_ricochet_trace"
				ricochetbullet.Force            = dmginfo:GetDamage() * 0.15
				ricochetbullet.Damage   = dmginfo:GetDamage() * 0.5
				ricochetbullet.Callback         = function(a, b, c)
						if (self.Ricochet) then  
						local impactnum
						if tr.MatType == MAT_GLASS then impactnum = 0 else impactnum = 1 end
						return self:RicochetCallback(bouncenum + impactnum, a, b, c) end
						end
 
		timer.Simple(0, function() attacker:FireBullets(ricochetbullet) end)
	   
		return {damage = true, effects = DoDefaultEffect}
end
 
 
/*---------------------------------------------------------
   Name: SWEP:BulletPenetrate()
-----------------------------------------------------*/
function SWEP:BulletPenetrate(bouncenum, attacker, tr, paininfo)
 
		local MaxPenetration
 
		if self.Primary.Ammo == "SniperPenetratedRound" then -- .50 Ammo
				MaxPenetration = 20
		elseif self.Primary.Ammo == "pistol" then -- pistols
				MaxPenetration = 9
		elseif self.Primary.Ammo == "357" then -- revolvers with big ass bullets
				MaxPenetration = 12
		elseif self.Primary.Ammo == "smg1" then -- smgs
				MaxPenetration = 14
		elseif self.Primary.Ammo == "ar2" then -- assault rifles
				MaxPenetration = 16
		elseif self.Primary.Ammo == "buckshot" then -- shotguns
				MaxPenetration = 5
		elseif self.Primary.Ammo == "slam" then -- secondary shotguns
				MaxPenetration = 5
		elseif self.Primary.Ammo ==     "AirboatGun" then -- metal piercing shotgun pellet
				MaxPenetration = 17
		else
				MaxPenetration = 14
		end
 
		local DoDefaultEffect = true
		// -- Don't go through metal, sand or player
	   
		if self.Primary.Ammo == "pistol" or
				self.Primary.Ammo == "buckshot" or
				self.Primary.Ammo == "slam" then self.Ricochet = true
		else
				if self.RicochetCoin == 1 then
				self.Ricochet = true
				elseif self.RicochetCoin >= 2 then
				self.Ricochet = false
				end
		end
	   
		if self.Primary.Ammo == "SniperPenetratedRound" then self.Ricochet = true end
	   
		if self.Primary.Ammo == "SniperPenetratedRound" then -- .50 Ammo
				self.MaxRicochet = 10
		elseif self.Primary.Ammo == "pistol" then -- pistols
				self.MaxRicochet = 2
		elseif self.Primary.Ammo == "357" then -- revolvers with big ass bullets
				self.MaxRicochet = 5
		elseif self.Primary.Ammo == "smg1" then -- smgs
				self.MaxRicochet = 4
		elseif self.Primary.Ammo == "ar2" then -- assault rifles
				self.MaxRicochet = 5
		elseif self.Primary.Ammo == "buckshot" then -- shotguns
				self.MaxRicochet = 0
		elseif self.Primary.Ammo == "slam" then -- secondary shotguns
				self.MaxRicochet = 0
		elseif self.Primary.Ammo ==     "AirboatGun" then -- metal piercing shotgun pellet
				self.MaxRicochet = 8
		end
	   
		if (tr.MatType == MAT_METAL and self.Ricochet == true and self.Primary.Ammo != "SniperPenetratedRound" ) then return false end
 
		// -- Don't go through more than 3 times
		if (bouncenum > self.MaxRicochet) then return false end
	   
		// -- Direction (and length) that we are going to penetrate
		local PenetrationDirection = tr.Normal * MaxPenetration
	   
		if (tr.MatType == MAT_GLASS or tr.MatType == MAT_PLASTIC or tr.MatType == MAT_WOOD or tr.MatType == MAT_FLESH or tr.MatType == MAT_ALIENFLESH) then
				PenetrationDirection = tr.Normal * (MaxPenetration * 2)
		end
			   
		local trace     = {}
		trace.endpos    = tr.HitPos
		trace.start     = tr.HitPos + PenetrationDirection
		trace.mask              = MASK_SHOT
		trace.filter    = {self.Owner}
		   
		local trace     = util.TraceLine(trace)
	   
		// -- Bullet didn't penetrate.
		if (trace.StartSolid or trace.Fraction >= 1.0 or tr.Fraction <= 0.0) then return false end
	   
		// -- Damage multiplier depending on surface
		local fDamageMulti = 0.5
	   
		if self.Primary.Ammo == "SniperPenetratedRound" then
				fDamageMulti = 1
		elseif(tr.MatType == MAT_CONCRETE or tr.MatType == MAT_METAL) then
				fDamageMulti = 0.3
		elseif (tr.MatType == MAT_WOOD or tr.MatType == MAT_PLASTIC or tr.MatType == MAT_GLASS) then
				fDamageMulti = 0.8
		elseif (tr.MatType == MAT_FLESH or tr.MatType == MAT_ALIENFLESH) then
				fDamageMulti = 0.9
		end
	   
		local damagedice = math.Rand(.85,1.3)
		local newdamage = self.Primary.Damage * damagedice
			   
		// -- Fire bullet from the exit point using the original trajectory
		local penetratedbullet = {}
				penetratedbullet.Num            = 1
				penetratedbullet.Src            = trace.HitPos
				penetratedbullet.Dir            = tr.Normal    
				penetratedbullet.Spread         = Vector(0, 0, 0)
				penetratedbullet.Tracer = 2
				penetratedbullet.TracerName     = "m9k_effect_mad_penetration_trace"
				penetratedbullet.Force          = 5
				penetratedbullet.Damage = paininfo:GetDamage() * fDamageMulti
				penetratedbullet.Callback       = function(a, b, c) if (self.Ricochet) then    
				local impactnum
				if tr.MatType == MAT_GLASS then impactnum = 0 else impactnum = 1 end
				return self:RicochetCallback(bouncenum + impactnum, a,b,c) end end     
			   
		timer.Simple(0, function() if attacker != nil then attacker:FireBullets(penetratedbullet) end end)
 
		return true
end