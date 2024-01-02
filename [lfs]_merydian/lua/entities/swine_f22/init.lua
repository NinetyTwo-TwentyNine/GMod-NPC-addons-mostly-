--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	
	
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 100 )
	ent:Spawn()
	ent:Activate()

	return ent
	
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimary( 0.02 )

	local startpos =  self:GetRotorPos()
	local tr = util.TraceLine( {
		start = startpos,
		endpos = (startpos + self:GetForward() * 50000),
		filter = function( e )
			return e ~= self
		end
	} )

	local Attacker = self
	if IsValid( self:GetDriver() ) then Attacker = self:GetDriver()
	elseif IsValid( self:AIGetSelf() ) then Attacker = self:AIGetSelf() end
	
	
	local bullet = {}
	bullet.Num 	= 1
	bullet.Src 	= self:LocalToWorld( Vector(-45,68,96) )
	bullet.Dir 	= (tr.HitPos - bullet.Src):Angle():Forward()
	bullet.Spread 	= Vector( 0.01,  0.01, 0 )
	bullet.Tracer	= 1
	bullet.TracerName	= "lfs_tracer_red"
	bullet.Force	= 25
	bullet.HullSize 	= 3
	bullet.Damage	= 40
	bullet.Attacker 	= Attacker
	bullet.AmmoType = "Pistol"
	bullet.Callback = function(att, tr, dmginfo)
		dmginfo:SetDamageType(DMG_AIRBOAT)
	end
	
	self:FireBullets( bullet )
	
	self:TakePrimaryAmmo( 1 )
end

function ENT:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 1 )
	
	self:EmitSound( "HS_MISSILE" )

	local TraceFilter = {self}
	if IsValid( self.wheel_R ) then
		table.insert( TraceFilter, self.wheel_R )
	end
	if IsValid( self.wheel_L ) then
		table.insert( TraceFilter, self.wheel_L )
	end
	if IsValid( self.wheel_C ) then
		table.insert( TraceFilter, self.wheel_C )
	end

	self.MirrorSecondary = not self.MirrorSecondary
	local Mirror = self.MirrorSecondary and -1 or 1
	
	local startpos =  self:GetRotorPos()
	local tr = util.TraceHull( {
		start = startpos,
		endpos = (startpos + self:GetForward() * 50000),
		mins = Vector( -80, -80, -80 ),
		maxs = Vector( 80, 80, 80 ),
		filter = function( e )
			return !table.HasValue(TraceFilter, e)
		end
	} )

	local Attacker = self
	if IsValid( self:GetDriver() ) then Attacker = self:GetDriver()
	elseif IsValid( self:AIGetSelf() ) then Attacker = self:AIGetSelf() end

	
	local ent = ents.Create( "lunasflightschool_missile" )
	local Pos = self:LocalToWorld( Vector(-58,155 * Mirror,50) )
	ent:SetPos( Pos + (tr.HitPos - Pos):Angle():Forward()*160 )
	ent:SetAngles( (tr.HitPos - Pos):Angle() )
	ent:Spawn()
	ent:Activate()
	ent:SetAttacker( Attacker )
	ent:SetInflictor( self )
	ent:SetOwner( self )
	ent:SetStartVelocity( self:GetVelocity():Length() )
	ent:SetDirtyMissile (true)

	for k,v in pairs(TraceFilter) do
		constraint.NoCollide( ent, v, 0, 0 )
		if table.HasValue(ent.Filter, v) then continue end
		table.insert(ent.Filter, v)
	end
	
	if tr.Hit then
		local Target = tr.Entity
		if IsValid( Target ) then
			if Target.Base && Target.Base:lower():StartWith("lunasflightschool_basescript") then
				ent:SetLockOn( Target )
				ent:SetStartVelocity( 0 )
			end
		end
	end
	
	self:TakeSecondaryAmmo( 1 )
end

function ENT:RunOnSpawn()
	self:SetBodygroup( 1, 1 )
	self:SetBodygroup( 2, 0 )
	if not self:GetAI() then
	end
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Fire1 = false
	local Fire2 = false

	local Driver = self:GetDriver()
	local AI = self:AIGetSelf()
	
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
					mins = Vector( -80, -80, -80 ),
					maxs = Vector( 80, 80, 80 ),
					filter = TraceFilter
				} )

				if IsValid(tr.Entity) then
					local TraceEntity = tr.Entity

					if TraceEntity != Target then
						TraceEntity = simfphys.IdentifyVehicleTarget(AI, TraceEntity)
					end

					if (self:AIGetRelationship(TraceEntity) == D_HT || self:AIGetRelationship(TraceEntity) == D_FR) && !(TraceEntity:IsPlayer() && GetConVarNumber("ai_ignoreplayers") == 1) then
						//if self:AITargetInfront( TraceEntity, 25 ) then
							Fire2 = true
						//end
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
	
	if self.OldFire2 ~= Fire2 then
		if Fire2 then
			self:SecondaryAttack()
		end
		self.OldFire2 = Fire2
	end
	
	if self.OldFire ~= Fire1 then
		
		if Fire1 then
			self.wpn1 = CreateSound( self, "F22_GUN_LOOP" )
			self.wpn1:Play()
			self:CallOnRemove( "stopmesounds1", function( ent )
				if ent.wpn1 then
					ent.wpn1:Stop()
				end
			end)
		else
			if self.OldFire == true then
				if self.wpn1 then
					self.wpn1:Stop()
				end
				self.wpn1 = nil
					
				self:EmitSound( "F22_GUN_LAST" )
			end
		end
		
		self.OldFire = Fire1
	end
end

function ENT:OnEngineStarted()
	self:SetBodygroup( 2, 1 )
	self:EmitSound( "JET_ENGINESTART" )
end

function ENT:OnEngineStopped()
	self:SetBodygroup( 2, 0 )
	self:EmitSound( "JET_ENGINESTOP" )
end

function ENT:OnLandingGearToggled( bOn )
	self:EmitSound( "lfs/bf109/gear.wav" )
	
	if bOn then
		self:SetBodygroup( 1, 1 )
	else
		self:SetBodygroup( 1, 1 )
	end
	
end

function ENT:GetMissileOffset()
	return Vector(0,0,75)
end