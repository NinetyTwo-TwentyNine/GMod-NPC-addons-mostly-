--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:RunOnSpawn()
	self:SetBodygroup( 14, 1 ) 
	self:SetBodygroup( 13, 1 ) 
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	if self:GetAI() then
		self:EmitSound( "BF109_FIRE_LASTSHOT" )
	end

	self:SetNextPrimary( 0.03 )
	
	self.MirrorPrimary = not self.MirrorPrimary
	
	local Mirror = self.MirrorPrimary and -1 or 1

	local Attacker = self
	if IsValid( self:GetDriver() ) then Attacker = self:GetDriver()
	elseif IsValid( self:AIGetSelf() ) then Attacker = self:AIGetSelf() end
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= self:LocalToWorld( Vector(109.29,7.13 * Mirror,92.85) )
	bullet.Dir 	= self:GetForward()
	bullet.Spread 	= Vector( 0.015,  0.015, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_tracer_green"
	bullet.Force	= 10
	bullet.HullSize 	= 5
	bullet.Damage	= 10
	bullet.Attacker 	= Attacker
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	
	self:FireBullets( bullet )
	
	self:TakePrimaryAmmo( 2 )
end

function ENT:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end

	if self:GetAI() then
		self:EmitSound( "BF109_FIRE2_LASTSHOT" )
	end

	self:SetNextSecondary( 0.15 )
	
	self.MirrorSecondary = not self.MirrorSecondary
	
	local Mirror = self.MirrorSecondary and -1 or 1

	local Attacker = self
	if IsValid( self:GetDriver() ) then Attacker = self:GetDriver()
	elseif IsValid( self:AIGetSelf() ) then Attacker = self:AIGetSelf() end
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= self:LocalToWorld( Vector(93.58,85.93 * Mirror,63.63) )
	bullet.Dir 	= self:LocalToWorldAngles( Angle(0,-0.5 * Mirror,0) ):Forward()
	bullet.Spread 	= Vector( 0.015,  0.015, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_tracer_red"
	bullet.Force	= 100
	bullet.HullSize 	= 10
	bullet.Damage	= 125
	bullet.Attacker 	= Attacker
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_DIRECT + DMG_BULLET)
	end
	self:FireBullets( bullet )
	
	self:TakeSecondaryAmmo()
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	local AI = self:AIGetSelf()

	local Fire1 = false
	local Fire2 = false

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
			if self:AITargetInfront( Target, 50 ) then
				Fire1 = true

				local TraceFilter = {self,self.wheel_L,self.wheel_R,self.wheel_C}
				local startpos =  self:GetRotorPos()
				local tr = util.TraceHull( {
					start = startpos,
					endpos = (startpos + self:GetForward() * 50000),
					mins = Vector( -30, -30, -30 ),
					maxs = Vector( 30, 30, 30 ),
					filter = TraceFilter
				} )
				if IsValid(tr.Entity) then
					local TraceEntity = tr.Entity

					if TraceEntity != Target then
						TraceEntity = simfphys.IdentifyVehicleTarget(AI, TraceEntity)
					end

					if (self:AIGetRelationship(TraceEntity) == D_HT || self:AIGetRelationship(TraceEntity) == D_FR) && !(TraceEntity:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1) then
						if self:AITargetInfront( TraceEntity, 25 ) then
							Fire2 = true
						end
					elseif self:AIGetRelationship(TraceEntity) == D_LI && !(TraceEntity:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1) then
						Fire1 = false
					end
				end
			end
		end
	end

	if Fire1 then
		self:PrimaryAttack()
	end

	if Fire2 then
		self:SecondaryAttack()
	end

	if self.OldFire ~= Fire1 then
		
		if Fire1 then
			if not self:GetAI() then
				self.wpn1 = CreateSound( self, "BF109_FIRE_LOOP" )
				self.wpn1:Play()
				self:CallOnRemove( "stopmesounds1", function( ent )
					if ent.wpn1 then
						ent.wpn1:Stop()
					end
				end)
			end
		else
			if self.OldFire == true then
				if self.wpn1 then
					self.wpn1:Stop()
				end
				self.wpn1 = nil

				if not self:GetAI() then
					self:EmitSound( "BF109_FIRE_LASTSHOT" )
				end
			end
		end
		
		self.OldFire = Fire1
	end
	
	if self.OldFire2 ~= Fire2 then

		if Fire2 then
			if not self:GetAI() then
				self.wpn2 = CreateSound( self, "BF109_FIRE2_LOOP" )
				self.wpn2:Play()
				self:CallOnRemove( "stopmesounds2", function( ent )
					if ent.wpn2 then
						ent.wpn2:Stop()
					end
				end)
			end
		else
			if self.OldFire2 == true then
				if self.wpn2 then
					self.wpn2:Stop()
				end
				self.wpn2 = nil

				if not self:GetAI() then
					self:EmitSound( "BF109_FIRE2_LASTSHOT" )
				end
			end
		end
		
		self.OldFire2 = Fire2
	end
end

function ENT:OnEngineStarted()
	self:EmitSound( "lfs/bf109/start.wav" )
end

function ENT:OnEngineStopped()
	self:EmitSound( "lfs/bf109/stop.wav" )
end

function ENT:OnLandingGearToggled( bOn )
	self:EmitSound( "lfs/bf109/gear.wav" )
end

function ENT:OnAICreated()
	self:SetBodygroup( 13, 0 )
end

function ENT:OnAIRemoved()
	self:SetBodygroup( 13, 1 )
end

function ENT:OnRemove()
end
