--SHITTY CODE BY MERYDIAN
--EVEN SHITTIER MODIFICATIONS BY KARLTROID51

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent.dOwnerEntLFS = ply
	ent:SetPos( tr.HitPos + tr.HitNormal * 90 )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:SetNextAltPrimary( delay )
	self.NextAltPrimary = CurTime() + delay
end

function ENT:CanAltPrimaryAttack()
	self.NextAltPrimary = self.NextAltPrimary or 0
	return self.NextAltPrimary < CurTime()
end

function ENT:TakeTertiaryAmmo()
	self:SetAmmoTertiary( math.max(self:GetAmmoTertiary() - 1,0) )
end
	
function ENT:AltPrimaryAttack( Driver, Pod, Dir )
	if not self:CanAltPrimaryAttack() then return end
	
	if not IsValid( Pod ) then return end

	local Attacker = self
	if IsValid( Driver ) then Attacker = Driver
	elseif IsValid( self:AIGetSelf() ) then Attacker = self:AIGetSelf() end
	
	local ID = self:LookupAttachment( "muzzle" )
	local Attachment = self:GetAttachment( ID )
	
	if not Attachment then return end

	self:SetNextAltPrimary( 0.05 )
	
	local TargetDir = -Attachment.Ang:Forward()
	
	-- ignore attachment angles and make aiming 100% accurate to player view direction
	/*local Forward = self:LocalToWorldAngles( Angle(20,0,0) ):Forward()
	local AimDirToForwardDir = math.deg( math.acos( math.Clamp( Forward:Dot( Dir ) ,-1,1) ) )
	if AimDirToForwardDir < 100 then
		TargetDir = Dir
	end*/
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= Attachment.Pos
	bullet.Dir 	= TargetDir
	bullet.Spread 	= Vector( 0.01,  0.01, 0.01 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_tracer_merydian_red"
	bullet.Force	= 30
	bullet.HullSize 	= 15
	bullet.Damage	= 25
	bullet.Attacker 	= Attacker
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
		
			local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
		util.Effect( "lfs_impact_cannon", effectdata )
	end
	
	self:FireBullets( bullet )
	
	self:TakeTertiaryAmmo()
end

function ENT:OnTick()
end

function ENT:RunOnSpawn()

	self:GetDriverSeat().ExitPos = Vector(155,-65,20)
	
	local GunnerSeat = self:AddPassengerSeat( Vector(215,-2,55), Angle(0,-90,0) )
	GunnerSeat.ExitPos = Vector(215,65,25)
	
	self:SetGunnerSeat( GunnerSeat )
	
	self:AddPassengerSeat( Vector(80,0,60), Angle(0,0,0) ).ExitPos = Vector(40,65,20)
	self:AddPassengerSeat( Vector(50,0,60), Angle(0,0,0) ).ExitPos = Vector(40,65,20)
	self:AddPassengerSeat( Vector(10,0,60), Angle(0,0,0) ).ExitPos = Vector(40,65,20)

	self:AddPassengerSeat( Vector(80,0,60), Angle(0,-180,0) ).ExitPos = Vector(40,-65,20)
	self:AddPassengerSeat( Vector(50,0,60), Angle(0,-180,0) ).ExitPos = Vector(40,-65,20)
	self:AddPassengerSeat( Vector(10,0,60), Angle(0,-180,0) ).ExitPos = Vector(40,-65,20)

	self:SetSkin(math.random(0,1))
end

function ENT:PrimaryAttack()
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 0.17 )
	self:TakePrimaryAmmo( 1 )
	
	self:EmitSound("ROCKET_POD_1")

	local Attacker = self
	if IsValid( self:GetDriver() ) then Attacker = self:GetDriver()
	elseif IsValid( self:AIGetSelf() ) then Attacker = self:AIGetSelf() end
	
	if m == nil or m >  table.Count(self.MISSILES) or m == 0 then m = 1 end
	local mpos = self:LocalToWorld(self.MISSILES[m])
	local Ang = self:WorldToLocal( mpos ).y > 0 and -1 or 1
	local ent = ents.Create(self.MISSILEENT)
	ent:SetPos(mpos)

	ent:SetAngles( self:LocalToWorldAngles( Angle(-0.35,0.025,0) ) )
	ent:SetAttacker( Attacker )
	ent:SetInflictor( self )
	ent:SetOwner( self )
	ent:Spawn()
	ent:Activate()
	constraint.NoCollide( ent, self, 0, 0 ) 
	m = m + 1
end

function ENT:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 1.5 )
	
	self:EmitSound("atgm_mi24_fire")
	
	local startpos =  self:GetRotorPos()
	local tr = util.TraceHull( {
		start = startpos,
		endpos = (startpos + self:GetForward() * 50000),
		mins = Vector( -40, -40, -40 ),
		maxs = Vector( 40, 40, 40 ),
		filter = self
	} )

	self.FireLeft = not self.FireLeft

	local Attacker = self
	if IsValid( self:GetDriver() ) then Attacker = self:GetDriver()
	elseif IsValid( self:AIGetSelf() ) then Attacker = self:AIGetSelf() end
	
	local ent = ents.Create( "lunasflightschool_missile" )
	local Pos = self:LocalToWorld( Vector(18,94 * (self.FireLeft and 1 or -1),52) )
	ent:SetPos( Pos )
	ent:SetAngles( (tr.HitPos - Pos):Angle() )
	ent:SetOwner( self )
	ent:Spawn()
	ent:Activate()
	ent:SetAttacker( Attacker )
	ent:SetInflictor( self )
	ent:SetStartVelocity( self:GetVelocity():Length() )
	//ent:SetDirtyMissile (true)
	
	constraint.NoCollide( ent, self, 0, 0 ) 
	
	if tr.Hit then
		local Target = tr.Entity
		if IsValid( Target ) then
			if Target:GetClass():lower() ~= "lunasflightschool_missile" then
				ent:SetLockOn( Target )
				ent:SetStartVelocity( 0 )
			end
		end
	end

	self:TakeSecondaryAmmo()
end

function ENT:OnEngineStarted()	
end

function ENT:OnEngineStopped()
end

function ENT:HandleWeapons(Fire1, Fire2, Fire3)
	local Fire1 = false
	local Fire2 = false
	local Fire3 = false

	local Driver = self:GetDriver()
	local AI = self:AIGetSelf()
	
	local Gunner = self:GetGunner()
	local GunnerSeat = self:GetGunnerSeat()
	local GunnerDir = self:GetForward()
	
	self.barrelSpinAdd = self.barrelSpinAdd and (self.barrelSpinAdd - self.barrelSpinAdd * FrameTime() * 5) or 0
	self.barrelSpin = self.barrelSpin and (self.barrelSpin + self.barrelSpinAdd) or 0

	if IsValid( Driver ) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		
		if self:GetAmmoSecondary() > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
	elseif IsValid( AI ) then
		local Target = self:AIGetTarget()
			
		if IsValid( Target ) then
			if self:AITargetInfront( Target, 25 ) then
				local TraceFilter = {self,self.wheel_L,self.wheel_R,self.wheel_C}
				local startpos =  self:GetRotorPos()
				local tr = util.TraceHull( {
					start = startpos,
					endpos = (startpos + self:GetForward() * 50000),
					mins = Vector( -40, -40, -40 ),
					maxs = Vector( 40, 40, 40 ),
					filter = TraceFilter
				} )
				if IsValid(tr.Entity) then
					local TraceEntity = tr.Entity

					local VehicleDriver = simfphys.IdentifyVehicleTarget(AI, TraceEntity)
					local ShouldFireGuidedMissiles = (TraceEntity != VehicleDriver)

					if TraceEntity != Target then
						TraceEntity = VehicleDriver
					end

					if (self:AIGetRelationship(TraceEntity) == D_HT || self:AIGetRelationship(TraceEntity) == D_FR) && !(TraceEntity:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1) then
						if ShouldFireGuidedMissiles then
							Fire2 = true
						else
							Fire1 = true
						end
					end
				end
			end
		end
	end
	
	if IsValid( GunnerSeat ) then
		if IsValid( Gunner ) then
			local EyeAng = Gunner:EyeAngles()
			local GunnerAng = GunnerSeat:WorldToLocalAngles( EyeAng )
		
			GunnerDir = GunnerAng:Forward()
		
			Gunner:CrosshairDisable()
		
			Fire3 = Gunner:KeyDown( IN_ATTACK )

			local TurretAng = self:WorldToLocalAngles( GunnerAng )

			self:SetPoseParameter("turret_yaw", TurretAng.y )
			self:SetPoseParameter("turret_pitch", TurretAng.p )
		elseif IsValid( AI ) then
			local Target = self:AIGetTarget()

			if IsValid(Target) && self:AICanSee(Target) then
				if self:AITargetInfront( Target, 65 ) then
					local ID = self:LookupAttachment( "muzzle" )
					local Attachment = self:GetAttachment( ID )

					local GunnerAng = (Target:BodyTarget(Attachment.Pos) - Attachment.Pos):Angle()
					GunnerDir = GunnerAng:Forward()
		
					if self:GetAmmoTertiary() > 0 then
						Fire3 = math.cos( CurTime() * 0.8 + self:EntIndex() * 1337 ) > -0.5
					end

					local TurretAng = self:WorldToLocalAngles( GunnerAng )

					self:SetPoseParameter("turret_yaw", TurretAng.y )
					self:SetPoseParameter("turret_pitch", TurretAng.p )
				end
			end
		end
	end



	self:SetPoseParameter("barrel_spin", self.barrelSpin )
		
	if Fire1 then
		self:PrimaryAttack()
	end

	if self.OldFire2 ~= Fire2 then
		if Fire2 then
			self:SecondaryAttack()
		end
		self.OldFire2 = Fire2
	end
	
	if Fire3 then
		self:AltPrimaryAttack( Gunner, GunnerSeat, GunnerDir )
		self.barrelSpinAdd = self.GunRPM
	end
	
	if self.OldFire3 ~= Fire3 then
		if Fire3 then
			self.wpn2 = CreateSound( self, "GSHG_FIRE_LOOP" )
			self.wpn2:Play()
			self:CallOnRemove( "stopmesounds2", function( ent )
				if ent.wpn2 then
					ent.wpn2:Stop()
				end
			end)
		else
			if self.OldFire3 == true then
				if self.wpn2 then
					self.wpn2:Stop()
				end
				self.wpn2 = nil
				
				self:EmitSound( "GSHG_LASTSHOT" )
			end
		end
		
		self.OldFire3 = Fire3
	end
end

function ENT:GetMissileOffset()
	return Vector(10,0,90)
end

function ENT:OnAICreated()
	self:SetBodygroup( 1, 1 )
end

function ENT:OnAIRemoved()
	self:SetBodygroup( 1, 0 )
end

function ENT:OnRotorDestroyed()
	self:EmitSound( "physics/metal/metal_box_break2.wav" )
	
	self:SetBodygroup( 1, 1 ) 
	
	self:SetHP(1)
	
	timer.Simple(2, function()
		if not IsValid( self ) then return end
		self:Destroy()
	end)
end