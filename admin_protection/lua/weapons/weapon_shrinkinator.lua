CreateClientConVar("shrinkinator_cl_viewmodel_zoom","0",true,false,"Should the viewmodel be zoomed in? (Redeploy to refresh)",0,1)

SWEP.Slot = 0
SWEP.SlotPos = 3

local SHRINK_TITLE = "Shrinkinator"

SWEP.NumModes = 3

SWEP.PrintName				= SHRINK_TITLE		
SWEP.Author					= "Pinhead Larry"

SWEP.Category				= "Frag Out Munitions"

SWEP.Instructions			= "Mouse 1: Mini\nMouse2: Wumbo\nReload: Return to Normal"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= true

SWEP.DrawCrosshair          = false
SWEP.NoSights               = true
SWEP.DrawAmmo 				= false
SWEP.DrawCrosshair          = false
SWEP.ViewModelFlip          = false

SWEP.UseHands               = true
SWEP.ViewModel              = Model("models/weapons/cstrike/c_c4.mdl")
SWEP.WorldModel             = Model("models/weapons/w_c4.mdl")

if CLIENT then
	SWEP.ViewModelFOV 			= 50
	SWEP.BounceWeaponIcon		= false
	SWEP.WepSelectIcon 			= surface.GetTextureID("shrinkinator/icon_shrinkinator")
end

SWEP.Primary.ClipSize       = GetConVar("shrinkinator_max_size"):GetInt() or 1000
SWEP.Primary.DefaultClip    = 100
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "StriderMinigun"
SWEP.Primary.Delay          = 0.1

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Delay        = 0.1

SWEP.DeploySound 			= "buttons/button1.wav"
SWEP.SizeSound 				= "items/medshotno1.wav"
SWEP.SizeSound2Vol			= 0.25
SWEP.ErrorSound 			= "buttons/button18.wav"
SWEP.ErrorPitch 			= 50

SWEP.UISound 				= "tools/ifm/beep.wav"
SWEP.ShowInfoPitch 			= 25
SWEP.NextInfoPitch 			= 50
SWEP.NextPagePitch			= 100

SWEP.TypeSound				= "buttons/button9.wav"
SWEP.DeleteSound			= "buttons/button16.wav"
SWEP.NumpadInfoSound1		= "buttons/button6.wav"
SWEP.NumpadInfoSound2		= "npc/turret_floor/click1.wav"

local screen_mat = Material("Models/effects/comball_tape")

SWEP.CanMouse1 = true
SWEP.CanReload = true
SWEP.CanMouse2 = true
SWEP.TimerWaiting = false

SWEP.SavedClip = 0

SWEP.StatSelected = 1
SWEP.IsError = false
SWEP.DrawStamp = 0

SWEP.FirstDraw = true

local draw_lenth = 1

function SWEP:SetupDataTables()
	self:NetworkVar("Int",0,"SelectedStat")
	self:NetworkVar("Int",1,"StatViewMode")
	self:NetworkVar("Bool",0,"ScreenError")
	self:NetworkVar("Bool",0,"StartKeypadEnter")
	self:NetworkVar("Bool",0,"FinishKeypadEnter")
	self:NetworkVar("Int",0,"KeypadEnteredNumber")
	if SERVER then
		util.AddNetworkString("ShrinkinatorKeypadCommand"..tostring(self:EntIndex()))
	end
end

function SWEP:SetError(bool)
	if bool and not self:GetError() then
		local own = self:GetOwner()
		if game.SinglePlayer() or (CLIENT and IsValid(own) and LocalPlayer() == own) then
			self:EmitSound(self.ErrorSound,100,self.ErrorPitch,0.156021)
		end
	end
	-- self:SetNWBool("IsError",bool)
	self:SetScreenError(tobool(bool))
end

function SWEP:GetError()
	return self:GetScreenError()
end

function SWEP:SetEntryNumber(num)
	-- self:GetOwner():ChatPrint("entry number set to"..tostring(num))
	self:SetNWInt("EntryNumber",num)
end

function SWEP:GetEntryNumber()
	return self:GetNWInt("EntryNumber",-1)
end

function SWEP:PressNumpad(key)
	self:SetNWInt("numpad",key)
end

function SWEP:GetNumpad()
	return self:GetNWInt("numpad",0)
end

function SWEP:SetStatView(bool)
	-- self:SetNWBool("StatView",bool)
	local set = 0
	if bool then
		set = 1
	end
	self:SetStatViewMode(set)
end

function SWEP:GetStatView()
	-- return self:GetNWBool("StatView",true)
	local int = self:GetStatViewMode()
	if int == 1 then
		return true
	else
		return false
	end
end

function SWEP:SetStat(int)
	self:SetSelectedStat(int)
end

function SWEP:GetStat()
	return self:GetSelectedStat()
end

function SWEP:Initialize()
	--fix for the austismo TFA users
	self.Bodygroups_V = {0}
	self.Bodygroups = {0}
	self.GetStat = false
	
	self:SetClip2(-1)
	self:SetError(false)
	self:SetStat(1)
	self:SetNWInt("savedclip",0)
	if engine.ActiveGamemode() == "sandbox" then
		self:SetDeploySpeed(1)
	end
	local own = self:GetOwner()
	if IsValid(own) then
		if SERVER then
		end
		if game.SinglePlayer() or (CLIENT and LocalPlayer() == own) then
			self:EmitSound(self.DeploySound,100,100,0.156021)
		end
	end
end

function SWEP:Deploy()
	if CLIENT then
		if GetConVar("shrinkinator_cl_viewmodel_zoom"):GetBool() then
			self.ViewModelFOV = 40
		else
			self.ViewModelFOV = 50
		end
	else
		net.Receive("ShrinkinatorKeypadCommand"..tostring(self:EntIndex()),function(len,ply)
			if not ply:IsValid() then 
				return
			end
			local entry_number = net.ReadInt(32)
			-- ply:ChatPrint(entry_number)
			self:DoKeypadEnterEvent(entry_number)
			-- ply:ConCommand("wep_shrink_send_keypad "..entry_number.." "..tostring(self))
		end)
	end
	local own = self:GetOwner()
	self.TimerWaiting = false
	if IsValid(own) then
		self:SetClip1(own:GetModelScale()*100)
		local savedclip = self.SavedClip
		self:SetNWInt("savedclip",savedclip)
		self:SetClip2(-1)
		if game.SinglePlayer() or (CLIENT and LocalPlayer() == own) then
			self:EmitSound(self.DeploySound,100,100,0.156021)
		end
		local time = SysTime()
		self:SetNWFloat("draw_time",time)
		self.DrawStamp = time
		local draw_lenth = 2
		if self.FirstDraw then
			draw_lenth = 3
		end
		timer.Simple(draw_lenth,function()
			if IsValid(self) then
				if self.DrawStamp == time then
					if self:Clip2() == -1 then
						self:SetClip2(savedclip)
						if self.FirstDraw then
							self.FirstDraw = false
						end
					end
				end
			end
		end)
	end
	return true
end

function SWEP:Think()
	local own = self.Owner
	if IsValid(own) then
		if not self.CanMouse1 then
			if not own:KeyDown(IN_ATTACK) then
				self.CanMouse1 = true
			end
		end
		if not self.CanReload then
			if not own:KeyDown(IN_RELOAD) then
				self.CanReload = true
			end
		end
		if not self.CanMouse2 then
			if not own:KeyDown(IN_ATTACK2) then
				self.CanMouse2 = true
			end
		end
		self:SetHoldType("slam")
		
		if self:GetError() then
			local error_size = self:Clip1()
			local clip2 = self:Clip2()
			if clip2 == 0 or clip2 == 2 then
				timer.Simple(0.1,function()
					if IsValid(self) then
						if self:Clip1() != error_size or not (own:KeyDown(IN_ATTACK2) or own:KeyDown(IN_RELOAD)) then
							self:SetError(false)
						end
					end
				end)
			elseif clip2 == 1 then
				timer.Simple(1.5,function()
					if IsValid(self) then
						self:SetError(false)
					end
				end)
			end
		end
	end
end

function SWEP:block_grow(own,clip)
	local bot,top = own:GetHull()
	local mult = clip/100
	local tr = util.TraceHull({
		start = own:GetPos(),
		endpos = own:GetPos(),
		filter = own,
		mins = bot*mult,
		maxs = top*mult,
		mask = MASK_SHOT_HULL
	})
	if tr.Hit and own:GetMoveType() != MOVETYPE_NOCLIP then
		self:SetError(true)
		return true
	end
end

function SWEP:DoKeypadEnterEvent(num)
	local own = self.Owner
	if own:IsValid() then
		if not timer.Exists("Mode2_M1_Timer_2") then
			local old_size = clip1
			timer.Simple(1.5,function()
				if own:IsValid() and self:IsValid() and own:GetActiveWeapon() == self then
					own:SetNWInt("desired_size",own:GetModelScale()*100)
				end
			end)
			timer.Create("Mode2_M1_Timer_2",2,1,function()
				if own:IsValid() and self:IsValid() and own:GetActiveWeapon() == self then
					self:SetFinishKeypadEnter(false)
					self.TimerWaiting = false
					self:SendWeaponAnim(ACT_VM_IDLE)
					local new_clip = num
					-- print(size)
					if (new_clip > self:Clip1() and self:block_grow(own,new_clip)) then
						self:EmitSound(self.ErrorSound,100,self.ErrorPitch,0.156021)
						return
					end
					-- local max_size = GetConVar("shrinkinator_max_size"):GetInt() or 1000
					local max_size = GetConVar("shrinkinator_max_size"):GetInt()
					local old_clip = self:Clip1()
					self:SetClip1(math.min(new_clip,max_size))
					local new_clip = self:Clip1()
					if old_clip != new_clip then
						self:EmitSound(self.SizeSound,1.35*math.pow(self:Clip1(),0.522879)+50,255-75.5595*math.pow(self:Clip1(),0.156021))
					end
					timer.Simple(0,function()
						if self:IsValid() and own:IsValid() then
							PlayerUpdateSize(own,self,false)
						end
					end)
				end
			end)
			self.TimerWaiting = true
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		end
	end
end

function SWEP:PrimaryAttack()
	if self.CanMouse1 then
		local clip1 = self:Clip1()
		local clip2 = self:Clip2()
		local own = self:GetOwner()
		
		if own:KeyDown(IN_ATTACK2) or own:KeyDown(IN_RELOAD) or self.TimerWaiting then
			return
		end
		
		local view_switch = false
		
		if clip2 == 2 then
			if not own:KeyDownLast(IN_ATTACK) and own:KeyDown(IN_USE) then
				view_switch = true
				self.CanMouse1 = false
			end
		end
		
		if view_switch and not self:GetError() then
			self:SetStatView(not self:GetStatView())
			if game.SinglePlayer() or (CLIENT and LocalPlayer() == own) then
				self:EmitSound(self.UISound,100,self.ShowInfoPitch,0.156021)
			end
		else
			if clip2 == 0 or clip2 == 2 then
				-- local min_size = GetConVar("shrinkinator_min_size"):GetInt() or 35
				local min_size = GetConVar("shrinkinator_min_size"):GetInt()
				if clip1 == min_size then
					if not own:KeyDownLast(IN_ATTACK) then
						self:EmitSound(self.ErrorSound,1.35*math.pow(self:Clip1(),0.522879)+50,255-75.5595*math.pow(self:Clip1(),0.156021),self.SizeSound2Vol)
					end
					return
				end
				if own:KeyDown(IN_ATTACK2) or own:KeyDown(IN_RELOAD) then
					return
				end
				-- local step = GetConVar("shrinkinator_rate"):GetInt() or 2
				local step = GetConVar("shrinkinator_rate"):GetInt()
				if IsValid(own) then
					if own:KeyDown(IN_DUCK) then
						return
					end
					self:SetClip1(math.max(clip1-step,min_size))
					
					self:EmitSound(self.SizeSound,1.35*math.pow(self:Clip1(),0.522879)+50,255-75.5595*math.pow(self:Clip1(),0.156021))
					PlayerUpdateSize(own,self,false)
				end
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if self.CanMouse2 then
		local clip1 = self:Clip1()
		local clip2 = self:Clip2()
		local own = self:GetOwner()
		
		if own:KeyDown(IN_ATTACK) or own:KeyDown(IN_RELOAD) or self.TimerWaiting then
			return
		end
		
		local stat_switch = false
		
		if clip2 == 2 then
			if not own:KeyDownLast(IN_ATTACK2) and own:KeyDown(IN_USE) then
				stat_switch = true
				self.CanMouse2 = false
			end
		end
		
		if stat_switch and not self:GetError() then
			self:SetStat(((self:GetSelectedStat())%6)+1)
			if game.SinglePlayer() or (CLIENT and LocalPlayer() == own) then
				self:EmitSound(self.UISound,100,self.NextInfoPitch,0.156021)
			end
		else
			if clip2 == 0 or clip2 == 2 then
				-- local max_size = GetConVar("shrinkinator_max_size"):GetInt() or 1000
				local max_size = GetConVar("shrinkinator_max_size"):GetInt()
				if clip1 == max_size then
					if not own:KeyDownLast(IN_ATTACK2) then
						self:EmitSound(self.ErrorSound,1.35*math.pow(self:Clip1(),0.522879)+50,255-75.5595*math.pow(self:Clip1(),0.156021),self.SizeSound2Vol)
					end
					return
				end
				if own:KeyDown(IN_ATTACK) or own:KeyDown(IN_RELOAD) then
					return
				end
				if IsValid(own) then
					-- local new_clip = clip1+(GetConVar("shrinkinator_rate"):GetInt() or 2)
					local new_clip = clip1+(GetConVar("shrinkinator_rate"):GetInt())
					if own:KeyDown(IN_DUCK) or self:block_grow(own,new_clip) then
						return
					end
					self:SetClip1(math.min(new_clip,max_size))
					self:EmitSound(self.SizeSound,1.35*math.pow(self:Clip1(),0.522879)+50,255-75.5595*math.pow(self:Clip1(),0.156021))
					PlayerUpdateSize(own,self,false)
				end
			end
			if clip2 == 1 then
				if not own:KeyDownLast(IN_ATTACK2) then
					self:EmitSound(self.NumpadInfoSound2,100,255,0.156021)
				end
			end
		end
	end
end

function SWEP:Reload()
	if self.CanReload then
		local clip1 = self:Clip1()
		local clip2 = self:Clip2()
		local own = self:GetOwner()
		
		if own:KeyDown(IN_ATTACK) or own:KeyDown(IN_ATTACK2) or self.TimerWaiting then
			return
		end
		
		local mode_switch = false
		
		if not own:KeyDownLast(IN_RELOAD) and own:KeyDown(IN_USE) then
			mode_switch = true
		end
		
		if mode_switch and not self:GetError() then
			local new_clip2
			if clip2 != -1 then
				new_clip2 = (clip2+1)%self.NumModes
			else
				new_clip2 = self.SavedClip
			end
			self.CanReload = false
			self:SetClip2(new_clip2)
			self.SavedClip = new_clip2
			if game.SinglePlayer() or (CLIENT and LocalPlayer() == own) then
				self:EmitSound(self.UISound,100,self.NextPagePitch,0.156021)
			end
		else
			if clip2 == 0 or clip2 == 2 then
				if clip1 == 100 then
					return
				end
				if own:KeyDown(IN_ATTACK) or own:KeyDown(IN_ATTACK2) then
					return
				end
				if IsValid(own) then
					-- local step = (GetConVar("shrinkinator_rate"):GetInt() or 2)
					local step = (GetConVar("shrinkinator_rate"):GetInt())
					if own:KeyDown(IN_DUCK) then
						return
					end
					if self:Clip1() < 100 and not self:block_grow(own,math.min(clip1+step,100)) then
						self:SetClip1(math.min(clip1+step,100))
						self:EmitSound(self.SizeSound,1.35*math.pow(self:Clip1(),0.522879)+50,255-75.5595*math.pow(self:Clip1(),0.156021))
					elseif self:Clip1() > 100 then
						self:SetClip1(math.max(clip1-step,100))
						self:EmitSound(self.SizeSound,1.35*math.pow(self:Clip1(),0.522879)+50,255-75.5595*math.pow(self:Clip1(),0.156021))
					end
					PlayerUpdateSize(own,self,false)
				end
			end
		end
	end
end

local function Draw3DText(pos,ang,scale,text,col,allign)
	cam.Start3D2D(pos,ang,scale)
		draw.DrawText(text,"Default",0,0,col,allign or TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

local function Draw3DText2(pos,ang,scale,text,col,allign)
	cam.Start3D2D(pos,ang,scale)
		draw.DrawText(text,"Default",0,0,col,allign or TEXT_ALIGN_LEFT)
	cam.End3D2D()
end

local function Draw3DText3(pos,ang,scale,text,col,font)
	cam.Start3D2D(pos,ang,scale)
		draw.DrawText(text,font,0,0,col,allign or TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

local function Draw3DRect(pos,ang,scale,col,rr,rx,ry,rw,rh)
	cam.Start3D2D(pos,ang,scale)
		draw.RoundedBox(1.5,rx,ry,rw,rh,col)
	cam.End3D2D()
end

local function DrawScreenBG(pos,ang,scale,col,x,y,w,h)
	cam.Start3D2D(pos,ang,scale)
		surface.SetDrawColor(col) -- Set the drawing color
		surface.DrawRect(x,y,w,h)
	cam.End3D2D()
end

local lines_length = {"____","_____","____","__","____","____"}

local RTEXT = "R:"
local RTEXT2 = "->"

function SWEP:PostDrawViewModel(vm,wep,own)
	local clip1 = self:Clip1()
	local clip2 = self:Clip2()
	-- local fill_max = GetConVar("shrinkinator_max_size"):GetInt() or 1000
	local fill_max = GetConVar("shrinkinator_max_size"):GetInt()
	-- local fill_min = GetConVar("shrinkinator_min_size"):GetInt() or 35
	local fill_min = GetConVar("shrinkinator_min_size"):GetInt()
	local bone = vm:LookupBone("v_weapon.c4")
	local bpos,bang = vm:GetBonePosition(bone)
	bang:RotateAroundAxis(bang:Up(),0)
	bang:RotateAroundAxis(bang:Right(),180)
	bang:RotateAroundAxis(bang:Forward(),-90)
	
	local x = 4.35
	local y = -1.53
	local z = 3.65
	local pos = bpos+bang:Forward()*x+bang:Right()*y+bang:Up()*z
	
	
	local error = self:GetError()
	
	local prog = (SysTime()-self:GetNWFloat("draw_time",0))/draw_lenth
	local prog = 1
	
	if prog > draw_lenth then
		prog = draw_lenth
	end
	
	local error_color = Color(255,0,0,math.sin(4*SysTime())*64+128+64)
	local col_green = Color(0,255*prog,0,255*prog)
	local col_orange = Color(255*prog,200*prog,0,255*prog)
	local col_orange_flash = Color(255,200,0,math.sin(4*SysTime())*64+128+64)
	local col_blue = Color(0,255*prog,255*prog,255*prog)
	
	local color
	local colors = {
		[0] = col_green,
		[1] = col_orange,
		[2] = col_blue
	}
	
	local sizemod1 = 1
	local offset1x = -0.015
	local offset1y = 0
	local sizemod2 = 1
	local offset2x = 0.5575
	local offset2y = 0
	local sizemod3 = 1
	local offset3x = 0.28
	local offset3y = 0
	
	local m1_top
	local m1_top2
	local m1_sides
	local m1_bottom
	local m1_bottom2
	
	local m2_top
	local m2_top2
	local m2_sides
	local m2_bottom
	local m2_bottom2
	
	local r_top
	local r_top2
	local r_sides
	local r_bottom
	local r_bottom2
	
	local rightdown = false
	local alt_action = false
	
	local alt_right = false
	local alt_left = false
	
	if IsValid(own) then
		if own:KeyDown(IN_ATTACK) then
			sizemod1 = 0.8
			offset1y = 0.15
		end
		if own:KeyDown(IN_ATTACK2) then
			sizemod2 = 0.8
			offset2y = 0.15
			rightdown = true
		end
		if own:KeyDown(IN_RELOAD) then
			sizemod3 = 0.8
			offset3y = 0.15
		end
		if own:KeyDown(IN_USE) then
			alt_action = true
		end
	end
	
	local draw_buttons = true
	
	local v_x = bpos+bang:Forward()*x
	local v_y = bpos+bang:Right()*y
	local v_z = bang:Up()*z
	local v_z_2 = bang:Up()*(z-0.03)
	
	local forwardx = bang:Forward()*x
	local forward = bang:Forward()
	
	local righty = bang:Right()*y
	local right = bang:Right()
	
	if clip2 == -1 then
			local savedclip = self:GetNWInt("savedclip",0)
			color = colors[savedclip]
			
			Draw3DText3(pos,bang,0.025,SHRINK_TITLE,color,"CloseCaption_BoldItalic")
			Draw3DText(bpos+forwardx*(1)+righty*.625+v_z,bang,0.025,"Beta 1.0",color)
			Draw3DText(bpos+forwardx*(1)+righty*.275+v_z,bang,0.03,"E+R: switch modes",color)
			draw_buttons = false
	elseif clip2 == 0 then
		if not error then
			-- own:ChatPrint("Mode 0")
			color = Color(0,0,0,255)
			color = colors[clip2]
			Draw3DText(pos,bang,0.05,"SIZE: "..self:Clip1().."%",color)
			Draw3DRect(pos,bang,0.05,color,2,-34,14,(clip1/fill_max)*68,3)
		else
			color = error_color
			Draw3DText(pos,bang,0.04,"ERROR: NEED\nMORE SPACE",color)
		end
		if not alt_action then
			Draw3DText3(bpos+forwardx*(0.715+offset3x)+right*(y+offset3y)*.3+v_z,bang,0.035*sizemod3,"   100",color,"default")
		end
		Draw3DText(bpos+forwardx*(0.75+offset1x)+right*(y+offset1y)*.3+v_z,bang,0.035*sizemod1,"    -",color)
		Draw3DText(bpos+forwardx*(0.743+offset2x)+right*(y+offset2y)*.3+v_z,bang,0.035*sizemod2,"    +",color)
	elseif clip2 == 1 then
		if not error then
			color = colors[clip2]
			
			local entry_number = self:GetEntryNumber()
			
			local entry_string = tostring(entry_number)
			
			if entry_number == -1 then
				entry_string = ""
			end
			
			if not timer.Exists("Mode2_M1_Timer") then
				local key = self:GetNumpad()
				if key > 36 and key < 47 then
					if key != 37 or string.len(entry_string) > 0 then
						local new_number = entry_string..key-37
						if tonumber(new_number) <= fill_max then
							entry_string = new_number
							self:EmitSound(self.TypeSound,100,100,0.156021)
							self:SetEntryNumber(tonumber(entry_string))
						end
					end
				end
				if key == 66 or key == 52 then
					entry_string = string.sub(entry_string,0,string.len(entry_string)-1)
					self:EmitSound(self.TypeSound,100,71,0.156021)
					self:SetEntryNumber(tonumber(entry_string))
				end
				if own:KeyDown(IN_RELOAD) and not own:KeyDownLast(IN_RELOAD) and not own:KeyDown(IN_USE) then
					self:EmitSound(self.DeleteSound,100,100,0.156021)
					self:SetEntryNumber(-1)
					self:PressNumpad(0)
				end
			end

			if ((own:KeyDown(IN_ATTACK) and not timer.Exists("Mode2_M1_Timer") and not own:KeyDown(IN_DUCK)) or key == 64) and string.len(entry_string) > 0 then
				if entry_number == clip1 then
					self:EmitSound(self.DeleteSound,100,100,0.156021)
					self:SetEntryNumber(-1)
					self:PressNumpad(0)
				elseif entry_number >= fill_min then
					local old_size = clip1
					timer.Create("Mode2_M1_Timer",2,1,function()
						if self:IsValid() and own:GetActiveWeapon() == self then
							timer.Simple(0.25,function()
								if self:IsValid() and self:Clip1() != old_size then
									self:SetEntryNumber(-1)
									self:PressNumpad(0)
								end
							end)
						end
					end)
					-- own:ConCommand("wep_shrink_send_keypad "..entry_number.." "..tostring(self))
					net.Start("ShrinkinatorKeypadCommand"..tostring(self:EntIndex()))
						net.WriteInt(entry_number,32)
					net.SendToServer()
				end
			end
			
			self:PressNumpad(0)
			if tobool(math.Round(SysTime()*2)%2) then
				entry_string = entry_string.."   "
			else
				entry_string = entry_string.."| "
			end
			if not own:KeyDown(IN_ATTACK2) then
				if own:KeyDownLast(IN_ATTACK2) then
					self:EmitSound(self.NumpadInfoSound2,100,200,0.156021)
				end
				Draw3DText2(bpos+forward*(x-1.7)+righty+v_z,bang,0.025,"Size: "..tostring(clip1).."%",color)
				Draw3DText2(bpos+forward*(x-0.08)+righty+v_z,bang,0.025,"Enter Number:",color)
				local blank_offset = 0
				if entry_string == "| " then
					blank_offset = -0.025
				end
				Draw3DText(bpos+forwardx*(1.05+blank_offset)+righty*.775+v_z,bang,0.05,entry_string,color)
			else
				Draw3DText(pos,bang,0.0225,"MAKE SURE NUM LOCK IS ON!",col_orange_flash)
				Draw3DText(bpos+forwardx+right*(y+0.3)+v_z,bang,0.027,"Accepted Keys:",color)
				Draw3DText(bpos+forwardx+right*(y+0.6)+v_z,bang,0.027,"Numpad 0-9, Backspace",color)
			end
			Draw3DText3(bpos+forwardx*(0.715+offset1x)+right*(y+offset1y)*.29+v_z,bang,0.03*sizemod1,"   a",color,"Marlett")
		else
			color = error_color
			Draw3DText(pos,bang,0.04,"ERROR: NEED\nMORE SPACE",color)
		end
		if not alt_action then
			Draw3DText3(bpos+forwardx*(0.735+offset3x)+right*(y+offset3y)*.24+v_z,bang,0.0225*sizemod3,"   CLEAR",color,"default")
		end
		Draw3DText3(bpos+forwardx*(0.735+offset2x)+right*(y+offset2y)*.238+v_z,bang,0.019*sizemod2,"   s",color,"Marlett")
	elseif clip2 == 2 then
		if not error then
			color = colors[clip2]
			
			local size_val = clip1
			local speed_val = math.Round(own:GetWalkSpeed()/2.2)
			local dmg_val = math.Round(math.max(clip1*math.pow((clip1/100),0.699),clip1))
			local dmg_val_inline = math.Round(dmg_val/100,1)
			if math.floor(dmg_val_inline) == math.ceil(dmg_val_inline) then
				dmg_val_inline = tostring(dmg_val_inline)..".0"
			end
			local hp_val = math.Round(math.max(clip1*clip1/100,clip1))
			local hp_val_inline = math.Round(100/((clip1/100)*(clip1/100)),1)
			if math.floor(hp_val_inline) == math.ceil(hp_val_inline) then
				hp_val_inline = tostring(hp_val_inline)..".0"
			end
			local step_val = math.Round(own:GetStepSize()/0.72)
			local mass_val = math.max(math.Round((clip1*clip1*clip1/10000)),0.25)
			
			if size_val == nil then
				size_val = 0
			end
			if speed_val == nil then
				speed_val = 0
			end
			if dmg_val == nil then
				dmg_val = 0
			end
			if dmg_val_inline == nil then
				dmg_val_inline = 0
			end
			if hp_val == nil then
				hp_val = 0
			end
			if hp_val_inline == nil then
				hp_val_inline = 0
			end
			if step_val == nil then
				step_val = 0
			end
			if mass_val == nil then
				mass_val = 0
			end
			
			local speed_space = " "
			if speed_val > 999 then
				speed_space = ""
			end
			
			local mass_space = " "
			if mass_val > 99999 then
				mass_space = ""
			end
			
			local dmg_space = " "
			if dmg_val > 9999 then
				dmg_space = ""
			end
			
			local lines = {
				"Size: "..size_val.."%",
				"Speed:"..speed_space..speed_val.."%",
				"Dmg:"..dmg_space..dmg_val.."%",
				"HP: "..hp_val.."%",
				"Step: "..step_val.."%",
				"Mass:"..mass_space..mass_val.."%"
			}
			--actual render for mode 3 starts here
			if not self:GetStatView() then
				local offset = -1.7
				for k,v in pairs(lines) do
					Draw3DText2(bpos+forward*(x+offset+(k-1)%2*1.7)+right*(y*((math.floor((k-.1)/2)-1)*-0.2)-1.22)+v_z,bang,0.025,v,color)
					if self:GetSelectedStat() == k then
						local hl = lines_length[k]
						Draw3DText2(bpos+forward*(x+offset+(k-1)%2*1.7)+right*(y*((math.floor((k-.1)/2)-1)*-0.2)-1.22)+v_z,bang,0.025,hl,color)
						Draw3DText2(bpos+forward*(x+offset+(k-1)%2*1.7)+right*(y*((math.floor((k-.1)/2)-1)*-0.2)-1.46)+v_z,bang,0.025,hl,color)
					end
				end
			else
				local k = self:GetSelectedStat()
				local offset = -1.7
				local line_desc = {
					"Your height and scale of\nyour hit and collision boxes",
					"Walking, sprinting, ducking,\nswimming, and ladder speed",
					"For every 1 weapon damage,\nyour weapons will deal "..tostring(dmg_val_inline),
					"Every 100 damage recieved\nwill deal you "..tostring(hp_val_inline).." damage",
					"Anyone under this size will\ndie if you step on them",
					"Mass is directly proportional\nto collision impact force"
				}
				Draw3DText(bpos+forward*(x)+right*(y-0.05)+v_z,bang,0.035,lines[k],color)
				Draw3DText2(bpos+forward*(x-1.7)+right*(y+0.4)+v_z,bang,0.025,line_desc[k],color)
			end
		else
			color = error_color
			Draw3DText(pos,bang,0.04,"ERROR: NEED\nMORE SPACE",color)
		end
			
		if alt_action then
			alt_right = true
			alt_left = true
			if not self:GetStatView() then
				Draw3DText3(bpos+forwardx*(0.745+offset1x)+right*(y+offset1y)*.238+v_z,bang,0.019*sizemod1,"   s",color,"Marlett")
			else
				Draw3DText3(bpos+forwardx*(0.75+offset1x)+right*(y+offset1y)*.238+v_z,bang,0.019*sizemod1,"   r",color,"Marlett")
			end
			Draw3DText3(bpos+forwardx*(0.745+offset2x)+right*(y+offset2y)*.25+v_z,bang,0.025*sizemod2,"  4",color,"Marlett")
		else
			Draw3DText(bpos+forwardx*(0.743+offset2x)+right*(y+offset2y)*.3+v_z,bang,0.035*sizemod2,"    +",color)
			Draw3DText(bpos+forwardx*(0.75+offset1x)+right*(y+offset1y)*.3+v_z,bang,0.035*sizemod1,"    -",color)
			Draw3DText3(bpos+forwardx*(0.715+offset3x)+right*(y+offset3y)*.3+v_z,bang,0.035*sizemod3,"   100",color,"default")
		end
	end
	
	-- local bar_pos_1 = 80*SysTime()
	-- local bar_alpha_1 = math.sin(0.5*SysTime())*16+16
	-- DrawScreenBG(bpos+forwardx+righty+v_z_2,bang,0.02,Color(color.r,color.g,color.b,bar_alpha_1*0.25),-99,(bar_pos_1-8)%109-17,197,4)
	-- DrawScreenBG(bpos+forwardx+righty+v_z_2,bang,0.02,Color(color.r,color.g,color.b,bar_alpha_1*0.5),-99,(bar_pos_1-4)%109-17,197,4)
	-- DrawScreenBG(bpos+forwardx+righty+v_z_2,bang,0.02,Color(color.r,color.g,color.b,bar_alpha_1),-99,bar_pos_1%109-17,197,4)
	
	local bar_pos_2 = 53.35871547*SysTime()
	local bar_alpha_2 = math.sin(0.21458751*SysTime())*8+8
	DrawScreenBG(bpos+forwardx+righty+v_z_2,bang,0.02,Color(color.r,color.g,color.b,bar_alpha_2*0.25),-99,(bar_pos_2-8)%109-17,197,4)
	DrawScreenBG(bpos+forwardx+righty+v_z_2,bang,0.02,Color(color.r,color.g,color.b,bar_alpha_2*0.5),-99,(bar_pos_2-4)%109-17,197,4)
	DrawScreenBG(bpos+forwardx+righty+v_z_2,bang,0.02,Color(color.r,color.g,color.b,bar_alpha_2),-99,bar_pos_2%109-17,197,4)
	
	local bar_pos_3 = 40.2154847*SysTime()
	local bar_alpha_3 = math.sin(0.1548851*SysTime())*14+14
	DrawScreenBG(bpos+forwardx+righty+v_z_2,bang,0.02,Color(color.r,color.g,color.b,bar_alpha_3*0.25),-99,(bar_pos_3-8)%109-17,197,4)
	DrawScreenBG(bpos+forwardx+righty+v_z_2,bang,0.02,Color(color.r,color.g,color.b,bar_alpha_3*0.5),-99,(bar_pos_3-4)%109-17,197,4)
	DrawScreenBG(bpos+forwardx+righty+v_z_2,bang,0.02,Color(color.r,color.g,color.b,bar_alpha_3),-99,bar_pos_3%109-17,197,4)
	
	if draw_buttons then
		Draw3DText(bpos+forwardx*(0.735+offset1x)+right*(y+offset1y)*.3+v_z,bang,0.035*sizemod1,"M1  ",color)
		Draw3DText(bpos+forwardx*(0.71+offset1x)+righty*.3+v_z,bang,0.04,"___",color)
		Draw3DText(bpos+forwardx*(0.71+offset1x)+righty*.58+v_z,bang,0.04,"___",color)
		Draw3DText(bpos+forwardx*(0.755+offset1x)+righty*.3+v_z,bang,0.04,"___",color)
		Draw3DText(bpos+forwardx*(0.755+offset1x)+righty*.58+v_z,bang,0.04,"___",color)
		Draw3DText(bpos+forwardx*(0.73+offset1x)+righty*.33+v_z,bang,0.035,"|       |",color)
		Draw3DText(bpos+forwardx*(0.73+offset1x)+righty*.26+v_z,bang,0.035,"|       |",color)
		
		Draw3DText(bpos+forwardx*(0.725+offset2x)+right*(y+offset2y)*.3+v_z,bang,0.035*sizemod2,"M2  ",color)
		Draw3DText(bpos+forwardx*(0.7+offset2x)+righty*.3+v_z,bang,0.04,"___",color)
		Draw3DText(bpos+forwardx*(0.7+offset2x)+righty*.58+v_z,bang,0.04,"___",color)
		Draw3DText(bpos+forwardx*(0.745+offset2x)+righty*.3+v_z,bang,0.04,"___",color)
		Draw3DText(bpos+forwardx*(0.745+offset2x)+righty*.58+v_z,bang,0.04,"___",color)
		Draw3DText(bpos+forwardx*(0.72+offset2x)+righty*.33+v_z,bang,0.035,"|       |",color)
		Draw3DText(bpos+forwardx*(0.72+offset2x)+righty*.26+v_z,bang,0.035,"|       |",color)
		
		Draw3DText(bpos+forwardx*(0.725+offset3x)+right*(y+offset3y)*.3+v_z,bang,0.035*sizemod3,"R        ",color)
		Draw3DText(bpos+forwardx*(0.728+offset3x)+righty*.3+v_z,bang,0.04,"_____",color)
		Draw3DText(bpos+forwardx*(0.728+offset3x)+righty*.58+v_z,bang,0.04,"_____",color)
		Draw3DText(bpos+forwardx*(0.713+offset3x)+righty*.3+v_z,bang,0.04,"_____",color)
		Draw3DText(bpos+forwardx*(0.713+offset3x)+righty*.58+v_z,bang,0.04,"_____",color)
		Draw3DText(bpos+forwardx*(0.72+offset3x)+righty*.33+v_z,bang,0.035,"|          |",color)
		Draw3DText(bpos+forwardx*(0.72+offset3x)+righty*.26+v_z,bang,0.035,"|          |",color)
				
		if alt_action and clip2 != -1 then
			Draw3DText(bpos+forwardx*(0.73+offset3x)+right*(y+offset3y)*.25+v_z,bang,0.025*sizemod3,"   NEXT",color)
			-- Draw3DText3(bpos+forwardx*(0.725+offset3x)+right*(y+offset3y)*.25+v_z,bang,0.025*sizemod3,"     4",color,"Marlett")
		end
	end
end

local function IterateInputs(player,wep,start,stop)
	if stop == nil then 
		stop = start
	end
	for i = start,stop do
		if input.IsKeyDown(i) then
			if not player:GetNWBool(i.."_pressed",true) then
				player:SetNWInt("numpad_pressed",i)
				player:SetNWBool(i.."_pressed",true)
				-- player:ChatPrint(input.GetKeyName(i))
				wep:PressNumpad(i)
			end
		else
			player:SetNWBool(i.."_pressed",false)
		end
	end
end

local function CheckNumpadInput(player)
	local wep = player:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "weapon_shrinkinator" and wep:Clip2() == 1 then
		IterateInputs(player,wep,37,46)
		IterateInputs(player,wep,52) --kp_del
		IterateInputs(player,wep,66) --Backspace
		IterateInputs(player,wep,64) --Enter
	end
end

if game.SinglePlayer() then
	hook.Add("Think","player_check_for_numpad_input",function()
		if CLIENT then
			for k,player in pairs(player.GetAll()) do
				CheckNumpadInput(player)
			end
		end
	end)
else
	hook.Add("PlayerTick","player_check_for_numpad_input",function(player,mv)
		if CLIENT then
			CheckNumpadInput(player)
		end
	end)
end

hook.Add("PlayerBindPress","player_block_numpad_bindings",function(ply,bind,pressed)
	local wep = ply:GetActiveWeapon()
	if wep:IsValid() and wep:GetClass() == "weapon_shrinkinator" and wep:Clip2() == 1 then
		local key = input.GetKeyCode(input.LookupBinding(bind,true))
		if (key > 36 and key < 47) or key == 52 or key == 66 then
			return true
		end
	end
end)

concommand.Add("wep_shrink_send_keypad",function(ply,cmd,args)
	if SERVER then
		print("SERVER: Concommand called from "..tostring(ply:Nick()))
	end
	local wep = ply:GetActiveWeapon()
	local num = tonumber(args[1])
	local ent = args[2].." "..args[3]
	-- local fill_max = GetConVar("shrinkinator_max_size"):GetInt() or 1000
	local fill_max = GetConVar("shrinkinator_max_size"):GetInt()
	-- local fill_min = GetConVar("shrinkinator_min_size"):GetInt() or 35
	local fill_min = GetConVar("shrinkinator_min_size"):GetInt()
	if wep:IsValid() and wep:GetClass() == "weapon_shrinkinator" and wep:Clip2() == 1 and isnumber(num) and num >= fill_min and num <= fill_max then
		if ent == tostring(wep) then
			wep:DoKeypadEnterEvent(num)
		end
	end
end)