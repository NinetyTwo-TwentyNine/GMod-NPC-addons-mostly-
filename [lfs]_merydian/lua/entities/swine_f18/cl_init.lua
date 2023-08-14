
include("shared.lua")


function ENT:DamageFX()
	local HP = self:GetHP()
	if HP == 0 or HP > self:GetMaxHP() * 0.5 then return end
	
	self.nextDFX = self.nextDFX or 0
	
	if self.nextDFX < CurTime() then
		self.nextDFX = CurTime() + 0.05
		
		local Size = 120

			local Pos = self:LocalToWorld( Vector(-200,0,15) )

			local effectdata = EffectData()
				effectdata:SetOrigin( Pos )
			util.Effect( "lfs_blacksmoke", effectdata )
		end
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	
	self.nextEFX = self.nextEFX or 0
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)
	
	local Driver = self:GetDriver()
	if IsValid( Driver ) then
		local W = Driver:KeyPressed( IN_FORWARD )
		if W ~= self.oldW then
			self.oldW = W
			if W then
				self.BoostAdd = 100
			end
		end
	end
	
	self.BoostAdd = self.BoostAdd and (self.BoostAdd - self.BoostAdd * FrameTime()) or 0
	
	if self.nextEFX < CurTime() then
		self.nextEFX = CurTime() + 0.01
		
		local emitter = ParticleEmitter( self:GetPos(), false )
		
		if emitter then
			local Mirror = false
			for i = 0,1 do
				local Sub = Mirror and 1 or -1
				local vOffset = self:LocalToWorld( Vector(-300,20 * Sub,90) )
				local vNormal = -self:GetForward()

				vOffset = vOffset + vNormal * 5

				local particle = emitter:Add( "effects/muzzleflash1", vOffset )
				if not particle then return end

				particle:SetVelocity( vNormal * math.Rand(500,1000) + self:GetVelocity() )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.13 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand(22,31) )
				particle:SetEndSize( math.Rand(0,4) )
				particle:SetRoll( math.Rand(-1,1) * 100 )

				particle:SetColor( 255, 199, 171 )
			
				Mirror = true
			end
			
			emitter:Finish()
		end
	end
end


function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local Low = 500
	local Mid = 700
	local High = 950
	
	if self.RPM1 then
		self.RPM1:ChangePitch( math.Clamp(70 + Pitch * 300 + Doppler,0,255) * 0.8 )
		self.RPM1:ChangeVolume( RPM < Low and 1 or 0, 1.5 )
	end
	
	if self.RPM2 then
		self.RPM2:ChangePitch(  math.Clamp(50 + Pitch * 320 + Doppler,0,255) * 0.8 )
		self.RPM2:ChangeVolume( (RPM >= Low and RPM < Mid) and 1 or 0, 1.5 )
	end
	
	if self.RPM3 then
		self.RPM3:ChangePitch(  math.Clamp(75 + Pitch * 110 + Doppler,0,255) * 0.8 )
		self.RPM3:ChangeVolume( (RPM >= Mid and RPM < High) and 1 or 0, 1.5 )
	end
	
	if self.RPM4 then
		self.RPM4:ChangePitch(  math.Clamp(90 + Pitch * 50 + Doppler,0,255) * 0.8 )
		self.RPM4:ChangeVolume( RPM >= High and 1 or 0, 1.5 )
	end
	
	if self.DIST then
		self.DIST:ChangePitch(  math.Clamp(math.Clamp( 50 + Pitch * 60, 50,255) + Doppler,0,255) )
		self.DIST:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0,1) )
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.RPM1 = CreateSound( self, "JET_ENGINERPM1" )
		self.RPM1:PlayEx(0,0)
		
		self.RPM2 = CreateSound( self, "JET_ENGINERPM2" )
		self.RPM2:PlayEx(0,0)
		
		self.RPM3 = CreateSound( self, "JET_ENGINERPM3" )
		self.RPM3:PlayEx(0,0)
		
		self.RPM4 = CreateSound( self, "JET_ENGINERPM4" )
		self.RPM4:PlayEx(0,0)
		
		self.DIST = CreateSound( self, "JET_ENGINEDIST" )
		self.DIST:PlayEx(0,0)
	else
		self:SoundStop()
	end
end

function ENT:OnRemove()
	self:SoundStop()
end

function ENT:SoundStop()
	if self.RPM1 then
		self.RPM1:Stop()
	end
	if self.RPM2 then
		self.RPM2:Stop()
	end
	if self.RPM3 then
		self.RPM3:Stop()
	end
	if self.RPM4 then
		self.RPM4:Stop()
	end
	
	if self.DIST then
		self.DIST:Stop()
	end
end

function ENT:AnimFins()
	local FT = FrameTime() * 10
	local Pitch = self:GetRotPitch()
	local Yaw = self:GetRotYaw()
	local Roll = -self:GetRotRoll()
	self.smPitch = self.smPitch and self.smPitch + (Pitch - self.smPitch) * FT or 0
	self.smYaw = self.smYaw and self.smYaw + (Yaw - self.smYaw) * FT or 0
	self.smRoll = self.smRoll and self.smRoll + (Roll - self.smRoll) * FT or 0
	
	
	--self:ManipulateBoneAngles( 14, Angle( 0,0,self.smRoll) ) --right wing flap
	--self:ManipulateBoneAngles( 44, Angle( 0,0,-self.smRoll) ) --left wing flap
	
end

function ENT:AnimRotor()

end

function ENT:AnimCabin()

end

function ENT:AnimLandingGear()
--3 left gear cover flap
--4 right gear cover flap
--5 front gear cover flap

	self.SMLG = self.SMLG and self.SMLG + ((1 - self:GetLGear()) - self.SMLG) * FrameTime() * 3 or 0
	self.SMRG = self.SMRG and self.SMRG + ((1 - self:GetRGear()) - self.SMRG) * FrameTime() * 8 or 0
	self.SMCG = self.SMCG and self.SMCG + (1 *  self:GetRGear() - self.SMCG) * FrameTime() * 15 or 2
	
	local gExp = self.SMRG ^ 5
	local gExp2 = self.SMRG ^ 8
	local gExp3 = self.SMCG ^ 0.3
	local gExp4 = self.SMCG ^ 0.4
	
	--RIGHT GEAR
	self:ManipulateBoneAngles( 5, Angle( 5,110,0) * gExp )
	self:ManipulateBoneAngles( 7, Angle( -5,-80,0) * gExp )
	self:ManipulateBoneAngles( 8, Angle( 0,100,0) * gExp )
	self:ManipulateBoneAngles( 9, Angle( 0,-65,0) * gExp )
	self:ManipulateBoneAngles( 38, Angle( -70,0,100) * gExp )
	self:ManipulateBonePosition( 53, Vector( -30,45,50) * gExp )
	
	--LEFT GEAR
	self:ManipulateBoneAngles( 39, Angle( 70,0,100) * gExp )
	self:ManipulateBoneAngles( 46, Angle( 0,-65,0) * gExp )
	self:ManipulateBoneAngles( 47, Angle( 5,110,0) * gExp )
	self:ManipulateBoneAngles( 48, Angle( -5,-80,0) * gExp )
	self:ManipulateBonePosition( 54, Vector( -30,-45,50) * gExp )
	
	--FRONT GEAR
	self:ManipulateBoneAngles( 6, Angle( 0,0,-35) * gExp )
	self:ManipulateBoneAngles( 36, Angle( 0,-80,0) * gExp )
	self:ManipulateBoneAngles( 37, Angle( 0,0,-110) * gExp )
	self:ManipulateBoneAngles( 50, Angle( 0,90,0) * gExp )
	self:ManipulateBonePosition( 52, Vector( 70,0,60) * gExp )
	
	
end

