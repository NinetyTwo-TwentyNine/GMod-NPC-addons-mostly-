-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE
-- DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

local VisibleTime = 0
local smVisible = 0
local zoom_mat = Material( "vgui/zoom" )
local mat = Material( "sprites/light_glow02_add" )

function ENT:LFSHudPaintPassenger( X, Y, ply )
	if ply ~= self:GetGunner() then return end

	local UsingGunCam = self.ToggledView
	
	local HitPlane = Vector(X*0.5,Y*0.5,0)

	local ID = self:LookupAttachment( "muzzle" )
	local Attachment = self:GetAttachment( ID )

	if Attachment then
		-- for the crosshair to be accurate CLIENT aiming code has to be exactly the same as SERVER aiming code
		
		local TargetDir = Attachment.Ang:Forward()
		/*local Dir = ply:EyeAngles():Forward()
		local Forward = self:LocalToWorldAngles( Angle(20,0,0) ):Forward()
		local AimDirToForwardDir = math.deg( math.acos( math.Clamp( Forward:Dot( Dir ) ,-1,1) ) )
		if AimDirToForwardDir < 100 then
			TargetDir = Dir
		end*/
		
		local Trace = util.TraceLine( {
			start = Attachment.Pos,
			endpos = (Attachment.Pos + TargetDir  * 50000),
			filter = self
		} )
		
		local pToScreen = Trace.HitPos:ToScreen()
		
		HitPlane = Vector(pToScreen.x,pToScreen.y,0)
	end
	
	local Time = CurTime()
	
	if self:GetAmmoTertiary() ~= self.OldAmmoTertiary then
		self.OldAmmoTertiary = self:GetAmmoTertiary()
		VisibleTime = Time + 2
	end
	
	local Visible = VisibleTime > Time
	smVisible = smVisible + ((Visible and 1 or 0) - smVisible) * FrameTime() * 10
	
	local wobl = ((VisibleTime - 1.9 > Time) and  self:GetAmmoTertiary() > 0) and math.cos( Time * 300 ) * 6 or 0
	
	local vD = 1 + (10 + wobl)
	local vD2 = 17 + (17 + wobl)
	local vD_2 = 1 + (44 + wobl)
	local vD2_2 = 10 + (19 + wobl)
	
	surface.SetDrawColor( Color(0,0,0,155) )
	surface.DrawLine( HitPlane.x + vD_2, HitPlane.y, HitPlane.x + vD2_2, HitPlane.y ) 
	surface.DrawLine( HitPlane.x - vD_2, HitPlane.y, HitPlane.x - vD2_2, HitPlane.y ) 
	surface.DrawLine( HitPlane.x, HitPlane.y + vD_2, HitPlane.x, HitPlane.y + vD2_2 ) 
	surface.DrawLine( HitPlane.x, HitPlane.y - vD_2, HitPlane.x, HitPlane.y - vD2_2 ) 
	
	surface.SetDrawColor( Color(255,250,250,255) )
	surface.DrawLine( HitPlane.x + vD, HitPlane.y, HitPlane.x + vD2, HitPlane.y ) 
	surface.DrawLine( HitPlane.x - vD, HitPlane.y, HitPlane.x - vD2, HitPlane.y ) 
	surface.DrawLine( HitPlane.x, HitPlane.y + vD, HitPlane.x, HitPlane.y + vD2 ) 
	surface.DrawLine( HitPlane.x, HitPlane.y - vD, HitPlane.x, HitPlane.y - vD2 ) 


	draw.SimpleText( self:GetAmmoTertiary(), "LFS_FONT", HitPlane.x + -18.2, HitPlane.y + 50, Color(255,255,255,55 + 200 * smVisible), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( self:GetAmmoPrimary(), "LFS_FONT", HitPlane.x + -18, HitPlane.y + 70, Color(255,255,255,55 + 200 * smVisible), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( self:GetAmmoSecondary(), "LFS_FONT", HitPlane.x + -18, HitPlane.y + 90, Color(255,255,255,55 + 200 * smVisible), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	
	
	if not UsingGunCam then return end
	
	local X = ScrW() * 0.5
	local Y = ScrH() * 0.5
	
	self.curZoom = self.curZoom or 90
	
	local Scale = (2.5 - self.curZoom / 70)
	
	local R = X * 0.2 * Scale
	
	surface.SetDrawColor( Color(255,255,255,255) )
	surface.SetMaterial( zoom_mat ) 
	surface.DrawTexturedRectRotated( X + X * 0.5, Y * 0.5, X, Y, 0 )
	surface.DrawTexturedRectRotated( X + X * 0.5, Y + Y * 0.5, Y, X, 270 )
	surface.DrawTexturedRectRotated( X * 0.5, Y * 0.5, Y, X, 90 )
	surface.DrawTexturedRectRotated( X * 0.5, Y + Y * 0.5, X, Y, 180 )
	
end

function ENT:GunCamera( view, ply )
	if ply == self:GetGunner() then
		local Zoom = ply:KeyDown( IN_ATTACK2 )
		
		if self.oldZoom ~= Zoom then
			self.oldZoom = Zoom
			if Zoom then
				self.ToggledView = not self.ToggledView
			else
				self.curZoom = 80
			end
		end
				
		if self.ToggledView then
			local ID = self:LookupAttachment( "muzzle" )
			local Attachment = self:GetAttachment( ID )

			if Attachment then
				view.origin = Attachment.Pos + Attachment.Ang:Up() * 15 + Attachment.Ang:Forward() * 5
			else
				view.origin = self:LocalToWorld( Vector(344.11,0,-62) )
			end
			
			view.fov = self.curZoom
		end
	end
	
	if self.oldToggledView ~= self.ToggledView then
		self.oldToggledView = self.ToggledView
		
		if self.ToggledView then
			surface.PlaySound("weapons/sniper/sniper_zoomin.wav")
		else
			surface.PlaySound("weapons/sniper/sniper_zoomout.wav")
		end
	end
	
	return view
end

function ENT:LFSCalcViewFirstPerson( view, ply )
	if ply ~= self:GetDriver() and ply ~= self:GetGunner() then
		view.angles = ply:GetVehicle():LocalToWorldAngles( ply:EyeAngles() )
	end
	
	return self:GunCamera( view, ply )
end

function ENT:LFSCalcViewThirdPerson( view, ply )
	return self:GunCamera( view, ply )
end

function ENT:LFSHudPaint( X, Y, data )
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local THR = RPM / self:GetLimitRPM()
	
	if self.ENG then
		self.ENG:ChangePitch( math.Clamp( math.min(RPM / self:GetIdleRPM(),1) * 75+ Doppler + THR * 20,0,255) )
		self.ENG:ChangeVolume( math.Clamp(THR,0.8,1) )
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound( self, "rebel_heli" )
		self.ENG:PlayEx(0,0)
	else
		self:SoundStop()
	end
end

function ENT:OnRemove()
	self:SoundStop()
end

function ENT:SoundStop()
	if self.DIST then
		self.DIST:Stop()
	end
	
	if self.ENG then
		self.ENG:Stop()
	end
end

function ENT:AnimFins()
end

function ENT:AnimRotor()
	local RotorBlown = self:GetRotorDestroyed()
	
	if not RotorBlown then
		local RPM = self:GetRPM()
		local PhysRot = RPM < 700
		self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * (PhysRot and 4 or 1.1)) or 0
		
		self:SetBodygroup( 1, PhysRot and 0 or 1 ) 
		self:SetBodygroup( 1, PhysRot and 0 or 1 ) 
		
		self:SetPoseParameter("rotor_spin", -self.RPM )
		self:InvalidateBoneCache()
	end
end

function ENT:AnimCabin()
end

function ENT:AnimLandingGear()
end

function ENT:ExhaustFX()
end

