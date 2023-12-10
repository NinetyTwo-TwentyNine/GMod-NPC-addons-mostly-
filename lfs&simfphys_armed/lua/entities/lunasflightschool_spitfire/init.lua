--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")


function ENT:RunOnSpawn()
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	if self:GetAI() then
		self:EmitSound( "SPITFIRE_FIRE_LASTSHOT" )
	end

	self:SetNextPrimary( 0.03 )
	
	self.MirrorPrimary = not self.MirrorPrimary
	
	local Mirror = self.MirrorPrimary and -1 or 1
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= self:LocalToWorld( Vector(136.19,74.97 * Mirror,53.7) )
	bullet.Dir 	= self:LocalToWorldAngles( Angle(0,-0.6 * Mirror,0) ):Forward()
	bullet.Spread 	= Vector( 0.018,  0.018, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_tracer_white"
	bullet.Force	= 100
	bullet.HullSize 	= 10
	bullet.Damage	= 26
	bullet.Attacker 	= self:GetDriver()
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_BULLET)
	end
	self:FireBullets( bullet )
	
	self:TakePrimaryAmmo( 2 )
end

function ENT:SecondaryAttack()
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
	elseif IsValid( AI ) then
		local Target = self:AIGetTarget()
			
		if IsValid( Target ) then
			if self:AITargetInfront( Target, 30 ) then
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

					if self:AIGetRelationship(TraceEntity) == D_LI && !(TraceEntity:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1) then
						Fire1 = false
					end
				end
			end
		end
	end

	if Fire1 then
		self:PrimaryAttack()
	end

	if self.OldFire ~= Fire1 then
		if Fire1 then
			if not self:GetAI() then
				self.wpn1 = CreateSound( self, "SPITFIRE_FIRE_LOOP" )
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
					self:EmitSound( "SPITFIRE_FIRE_LASTSHOT" )
				end
			end
		end
		
		self.OldFire = Fire1
	end
end

function ENT:OnEngineStarted()
	self:EmitSound( "lfs/spitfire/start.wav" )
end

function ENT:OnEngineStopped()
	self:EmitSound( "lfs/spitfire/stop.wav" )
end

function ENT:OnLandingGearToggled( bOn )
	self:EmitSound( "lfs/bf109/gear.wav" )
end
