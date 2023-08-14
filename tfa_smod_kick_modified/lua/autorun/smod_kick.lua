if SERVER then
	include("kick_animapi/boneanimlib.lua")
end
if CLIENT then	
	include("kick_animapi/cl_boneanimlib.lua") 
end

RegisterLuaAnimation('fe_g_kick', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 90
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -140,
					RR = -20,
					RF = 10
				},
																['ValveBiped.Bip01_Spine1'] = {
					RU = 10
				},
								['ValveBiped.Bip01_R_Foot'] = {
					RU = -30
				}
			},
			FrameRate = 4
		},
				{
			BoneInfo = {
				['ValveBiped.Bip01_R_Calf'] = {
					RU = -20
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = -90,
					RR = -20,
					RF = 10
				},
												['ValveBiped.Bip01_Spine1'] = {
					RU = -10
				},
								['ValveBiped.Bip01_R_Foot'] = {
					RU = 20
				}
			},
			FrameRate = 6
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_R_Calf'] = {
					RU = 0
				},
				['ValveBiped.Bip01_R_Thigh'] = {
					RU = 0
				},
												['ValveBiped.Bip01_Spine1'] = {
					RU = 0
				},
								['ValveBiped.Bip01_R_Foot'] = {
					RU = 0
				}
			},
			FrameRate = 2
		}
	},
	Type = 0
})

local kicktime = 2.3

if !ConVarExists("kick_powerscale") then
    CreateConVar("kick_powerscale", '1', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_chancetoblowdoor") then
    CreateConVar("kick_chancetoblowdoor", '5', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_blowdoormulforce") then
    CreateConVar("kick_blowdoormulforce", '1', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_blowdoorforce") then
    CreateConVar("kick_blowdoorforce", '300', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_blowdoor") then
    CreateConVar("kick_blowdoor", '0', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_unlock") then
    CreateConVar("kick_unlock", '1', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_effect") then
    CreateConVar("kick_effect", '1', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_playersound") then
    CreateConVar("kick_playersound", '1', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_maxdamage") then
    CreateConVar("kick_maxdamage", '10', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_mindamage") then
    CreateConVar("kick_mindamage", '10', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_physmul") then
    CreateConVar("kick_physmul", '5', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_range") then
    CreateConVar("kick_range", '65', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_time") then
    CreateConVar("kick_time", '2.3', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_hitshake") then
    CreateConVar("kick_hitshake", '1', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_hitragdollforce") then
    CreateConVar("kick_hitragdollforce", '100', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_doorrespawntime") then
    CreateConVar("kick_doorrespawntime", '25', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_damagebyspeed") then
    CreateConVar("kick_damagebyspeed", '1', FCVAR_ARCHIVE)
end

if !ConVarExists("kick_damagebyspeeddiv") then
    CreateConVar("kick_damagebyspeeddiv", '10', FCVAR_ARCHIVE)
end

function CalcPlayerModelsAngle( ply )
    local defans = Angle(-90,0,0)
	if ply:Health() <= 0 then return defans end
	local StartAngle = ply:EyeAngles()
	if !StartAngle then return defans end
	local CalcAngle = Angle( (StartAngle.p)/1.1-20 , StartAngle.y, 0)
	if !CalcAngle then return StartAngle end
	return CalcAngle
end

function CalcPlayerModelsAngle2( ply )
    local defans = Angle(-90,0,0)
	if ply:Health() <= 0 then return defans end
	local StartAngle = ply:EyeAngles()
	if !StartAngle then return defans end
	local CalcAngle = Angle( -30 , StartAngle.y, 0)
	if !CalcAngle then return StartAngle end
	return CalcAngle
end

hook.Add("PopulateToolMenu", "KickingOptionsMenu", function()
        spawnmenu.AddToolMenuOption("Options", "Smod Kick", "kick_options", "Options", "", "", function(panel)

            panel:AddControl("toggle", {
                label = "Enable BlowDoor",
                command = "kick_blowdoor"
            })

            panel:AddControl("toggle", {
                label = "Kick unlock door",
                command = "kick_unlock"
            })

            panel:AddControl("toggle", {
                label = "Kick hit effect",
                command = "kick_effect"
            })

            panel:AddControl("toggle", {
                label = "Kick hit shake",
                command = "kick_hitshake"
            })

            panel:AddControl("toggle", {
                label = "Kick player sounds",
                command = "kick_playersound"
            })

			panel:AddControl("toggle", {
				label = "Kick damage by speed",
				command = "kick_damagebyspeed"
            })
			
            panel:AddControl("slider", {
                type = "float",
                label = "Kick power scale",
                command = "kick_powerscale",
                min = 0,
                max = 1000,
            })
			panel:AddControl("slider", {
                type = "float",
                label = "Kick chance do blowdoor",
                command = "kick_chancetoblowdoor",
                min = 0,
                max = 10,
            })
			panel:AddControl("slider", {
                type = "float",
                label = "Kick blowdoor mul force",
                command = "kick_blowdoormulforce",
                min = 1,
                max = 1000,
            })
			panel:AddControl("slider", {
                type = "float",
                label = "Kick blowdoor force",
                command = "kick_blowdoorforce",
                min = 1,
                max = 1000,
            })
			panel:AddControl("slider", {
                type = "float",
                label = "Kick max damage",
                command = "kick_maxdamage",
                min = 1,
                max = 1000,
            })
			panel:AddControl("slider", {
                type = "float",
                label = "Kick min damage",
                command = "kick_mindamage",
                min = 1,
                max = 1000,
            })
			panel:AddControl("slider", {
                type = "float",
                label = "Kick delay",
                command = "kick_time",
                min = 1,
                max = 1000,
            })
			panel:AddControl("slider", {
                type = "float",
                label = "Kick phys mul",
                command = "kick_physmul",
                min = 1,
                max = 1000,
            })
			panel:AddControl("slider", {
                type = "float",
                label = "Kick range",
                command = "kick_range",
                min = 1,
                max = 1000,
            })
			panel:AddControl("slider", {
                type = "float",
                label = "Kick hit ragdoll force",
                command = "kick_hitragdollforce",
                min = 1,
                max = 1000,
            })
			panel:AddControl("slider", {
                type = "float",
                label = "Door respawn time",
                command = "kick_doorrespawntime",
                min = 1,
                max = 1000,
            })
			panel:AddControl("slider", {
                type = "float",
                label = "Damage by speed divider",
                command = "kick_damagebyspeeddiv",
                min = 1,
                max = 100,
            })
        end)
    end)

if CLIENT then

local function Kicking( )
	local ply = LocalPlayer()
	
	if !IsValid(ply) then return end
	
    if !ply:Alive() then return false end
    if !ply.StopKick then
        ply.StopKick = CurTime() + 1
    elseif ply.StopKick and ply.StopKick < CurTime() then
        ply:SetNWBool("Kicking",net.ReadBool())
        ply.KickTime = CurTime()
        ply.StopKick = ply.KickTime + 1
    end
end
net.Receive( "Kicking", Kicking )

local kickvmoffset = Vector(3,-1.5,-8)

function CreateLegs()
for k, v in pairs(player.GetAll()) do

	local Kicking = v:GetNWBool("Kicking",false)
    if GetViewEntity() == v and (!v.ShouldDrawLocalPlayer or !v:ShouldDrawLocalPlayer() ) and Kicking and v.StopKick and v.StopKick > CurTime() then
		local off = Vector(kickvmoffset.x,kickvmoffset.y,kickvmoffset.z)
		off:Rotate(CalcPlayerModelsAngle(v))
		if !IsValid(v.CreateLegs) then
			--print("Creating Main Leg")
			v.CreateLegs = ClientsideModel("models/weapons/tfa_kick.mdl", RENDERGROUP_TRANSLUCENT)
			v.CreateLegs:Spawn()
			v.CreateLegs:SetPos(v:GetShootPos()+off)
			v.CreateLegs:SetAngles(CalcPlayerModelsAngle(v))
			v.CreateLegs:SetParent(v)
			v.CreateLegs:SetNoDraw(true)
			v.CreateLegs:DrawModel()
			v.CreateLegs:SetCycle(0)
			v.CreateLegs:SetSequence(2)
			v.CreateLegs:SetPlaybackRate( 0.5 ) 
			v.CreateLegs.LastTick = CurTime()
		else
			--print("Updating Main Leg")
			v.CreateLegs:SetPos(v:GetShootPos()+off)
			v.CreateLegs:SetAngles(CalcPlayerModelsAngle(v))
			v.CreateLegs:FrameAdvance( CurTime() - v.CreateLegs.LastTick )		
		    v.CreateLegs.LastTick = CurTime()
		end
		if v:EyeAngles().x <= -20 then
			v.CreateLegs:SetAngles(CalcPlayerModelsAngle2(v))
			end
		if !IsValid(v.CreatePMLegs)  then
			--print("Creating PM Leg")
			v.CreatePMLegs = ClientsideModel(string.Replace(v:GetModel(),"models/models/","models/"), RENDERGROUP_TRANSLUCENT)
			v.CreatePMLegs:Spawn()
			v.CreatePMLegs:SetSkin(v:GetSkin())
			v.CreatePMLegs:SetBodygroup( 1, v:GetBodygroup(1))
			v.CreatePMLegs:SetBodygroup( 2, v:GetBodygroup(2))
			v.CreatePMLegs:SetBodygroup( 3, v:GetBodygroup(3))
			v.CreatePMLegs:SetBodygroup( 4, v:GetBodygroup(4))
			v.CreatePMLegs:SetBodygroup( 5, v:GetBodygroup(5))
			v.CreatePMLegs:SetBodygroup( 6, v:GetBodygroup(6))
			v.CreatePMLegs:SetBodygroup( 7, v:GetBodygroup(7))
			v.CreatePMLegs:SetBodygroup( 8, v:GetBodygroup(8))
			v.CreatePMLegs:SetBodygroup( 9, v:GetBodygroup(9))
			v.CreatePMLegs:SetBodygroup( 10, v:GetBodygroup(10))
			v.CreatePMLegs:SetParent(v.CreateLegs)
			v.CreatePMLegs:SetPos(v:GetShootPos()+off)
			v.CreatePMLegs:SetAngles(CalcPlayerModelsAngle(v))
			v.CreatePMLegs:SetNoDraw(false)
			v.CreatePMLegs:AddEffects(EF_BONEMERGE)
			v.CreatePMLegs:DrawModel()
			v.CreatePMLegs:SetPlaybackRate( 0.5 ) 
			v.CreatePMLegs.LastTick = CurTime()
		else
			--print("Updating PM Leg")
			v.CreatePMLegs:SetPos(v:GetShootPos()+off)
			v.CreatePMLegs:SetAngles(CalcPlayerModelsAngle(v))
			v.CreatePMLegs:FrameAdvance( CurTime() - v.CreateLegs.LastTick )
            v.CreatePMLegs:DrawModel()			
		    v.CreatePMLegs.LastTick = CurTime()
		end
	else
			
			if v.CreateLegs then
				if IsValid(v.CreateLegs) then
					v.CreateLegs.SetNoDraw(v.CreateLegs,true)
					v.CreateLegs.SetPos(v.CreateLegs,Vector(0, 0, 0))
					v.CreateLegs.SetAngles(v.CreateLegs,Angle(0,0,0))
					v.CreateLegs.SetRenderOrigin(v.CreateLegs,Vector(0, 0, 0))
					v.CreateLegs.SetRenderAngles(v.CreateLegs,Angle(0,0,0))
				end
				
				local tmpcreatelegs = v.CreateLegs
				timer.Simple(0.1,function()
					if tmpcreatelegs then
						SafeRemoveEntity(tmpcreatelegs)
					end
				end)
				
				v.CreateLegs = nil
				
			end
			
			if v.CreatePMLegs then
				--print("Removing Created PM Leg")
				if IsValid(v.CreatePMLegs) then
					v.CreatePMLegs.SetNoDraw(v.CreatePMLegs,true)
					v.CreatePMLegs.SetPos(v.CreatePMLegs,Vector(0, 0, 0))
					v.CreatePMLegs.SetAngles(v.CreatePMLegs,Angle(0,0,0))
					v.CreatePMLegs.SetRenderOrigin(v.CreatePMLegs,Vector(0, 0, 0))
					v.CreatePMLegs.SetRenderAngles(v.CreatePMLegs,Angle(0,0,0))
				end
				
				local tmpcreatelegs = v.CreatePMLegs
				timer.Simple(0.1,function()
					if tmpcreatelegs then
						SafeRemoveEntity(tmpcreatelegs)
					end
				end)
				
				v.CreatePMLegs = nil
			end
			
			v.Kicking = false
	end
end
end
hook.Add("Think","CreateLegs",CreateLegs)
end

local ImGirl = {
		"models/player/zelpa/female_01_b.mdl",
		"models/player/zelpa/female_02_b.mdl",
		"models/player/zelpa/female_03_b.mdl",
		"models/player/zelpa/female_04_b.mdl",
		"models/player/zelpa/female_06_b.mdl",
		"models/player/zelpa/female_07_b.mdl",
		"models/player/zelpa/female_01.mdl", 
		"models/player/zelpa/female_02.mdl",
		"models/player/zelpa/female_03.mdl",
		"models/player/zelpa/female_04.mdl",
		"models/player/zelpa/female_06.mdl",
		"models/player/zelpa/female_07.mdl",
}

function GGetSound(mdl)

	if table.HasValue(ImGirl,mdl) or string.find(mdl, "female") then

		return "vo/npc/female01/pain0"..math.random(1,5)..".wav"

	end	

	return 'vo/npc/male01/pain0'..math.random(1,6)..'.wav'

end

function KickHit(ply)
   
    local trace = ply:GetEyeTrace()
	if trace == nil or ply:EyeAngles().x <= -20 then return end
    local phys = trace.Entity:GetPhysicsObject()
	if phys == nil then return end
	
    local damage = math.random(GetConVarNumber("kick_mindamage"),GetConVarNumber("kick_maxdamage")) * GetConVarNumber("kick_powerscale")
	
	if GetConVarNumber("kick_damagebyspeed") >= 1 then
	    damage = damage + math.Clamp(ply:GetVelocity():Length() / GetConVarNumber("kick_damagebyspeeddiv"), 0, ply:GetVelocity():Length())
	end
	
	if ply:GetNWBool("Extention_Strength") then
	    damage = damage * 3
	end

    if SERVER then
    if trace.HitPos:Distance(ply:GetShootPos()) <= GetConVarNumber("kick_range") then -- If we're in range
	    if GetConVarNumber("kick_hitshake") >= 1 then
		    local shake = ents.Create( "env_shake" )
		    shake:SetOwner(ply)
		    shake:SetPos( trace.HitPos )
		    shake:SetKeyValue( "amplitude", "2500" )
		    shake:SetKeyValue( "radius", "100" )
		    shake:SetKeyValue( "duration", "0.5" )
		    shake:SetKeyValue( "frequency", "255" )
		    shake:SetKeyValue( "spawnflags", "4" )	
		    shake:Spawn()
		    shake:Activate()
		    shake:Fire( "StartShake", "", 0 )
		end	
        if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then	
	        if string.find(trace.Entity:GetClass(),"npc") and trace.Entity:Health() <= damage then
		    if IsValid(phys) then
	        	phys:ApplyForceOffset(ply:GetAimVector():GetNormalized() * (damage * GetConVarNumber("kick_physmul")), trace.HitPos)
		    end
	            trace.Entity:SetVelocity(ply:GetAimVector():GetNormalized() * (damage * GetConVarNumber("kick_physmul")))
			elseif string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			    phys:ApplyForceOffset(ply:GetAimVector():GetNormalized() * ((damage * GetConVarNumber("kick_hitragdollforce") * GetConVarNumber("kick_physmul")) * GetConVarNumber("kick_powerscale")), trace.HitPos)
	        end
			if  GetConVarNumber("kick_playersound") >= 1 then
			ply:EmitSound(GGetSound(ply:GetModel()), 50)
			end
			trace.Entity:EmitSound("physics/body/body_medium_impact_hard6.wav", 100, math.random(90, 110))
			ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
	        trace.Entity:TakeDamage(damage, ply, ply)
	    elseif trace.Entity:IsWorld() then
			if  GetConVarNumber("kick_playersound") >= 1 then
			ply:EmitSound(GGetSound(ply:GetModel()), 50)
			end
			ply:EmitSound("physics/body/body_medium_impact_hard1.wav", 100, math.random(90, 110))
			ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
			 if GetConVarNumber("kick_effect") >= 1 then		
			    local fx 	= EffectData()
	            fx:SetStart(trace.HitPos)
	            fx:SetOrigin(trace.HitPos)
	            fx:SetNormal(trace.HitNormal)
	            util.Effect("kick_groundhit",fx)
	        end			
		elseif trace.Entity:GetClass() == "func_door_rotating" or trace.Entity:GetClass() == "prop_door_rotating" then
		    if math.random(1,GetConVarNumber("kick_chancetoblowdoor")) == 1 and GetConVarNumber("kick_blowdoor") >= 1 and trace.Entity:GetClass() == "prop_door_rotating" then
			    FakeDoor(trace.Entity, ply, damage)
				if  GetConVarNumber("kick_playersound") >= 1 then
				ply:EmitSound(GGetSound(ply:GetModel()), 50)
				end
				trace.Entity:EmitSound("physics/wood/wood_panel_impact_hard1.wav", 100, math.random(90, 110))
	            ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
			else	
				ply.oldname = ply:GetName()
				ply:SetName( "bashingpl" .. ply:EntIndex() )
				trace.Entity:SetKeyValue( "Speed", "500" )
	            trace.Entity:Fire( "openawayfrom", "bashingpl" .. ply:EntIndex() , .02 )
				timer.Simple(0.3, function()
				    trace.Entity:SetKeyValue( "Speed", "100" )
				end, trace.Entity)
				if GetConVarNumber("kick_unlock") <= 0 then
				if  GetConVarNumber("kick_playersound") >= 1 then
				ply:EmitSound(GGetSound(ply:GetModel()), 50)
				end
				trace.Entity:EmitSound("physics/wood/wood_panel_impact_hard1.wav", 100, math.random(90, 110))
			else
			if  GetConVarNumber("kick_playersound") >= 1 then
			ply:EmitSound(GGetSound(ply:GetModel()), 50)
			end
			trace.Entity:EmitSound("physics/wood/wood_plank_break1.wav", 100, math.random(90, 110))
			trace.Entity:Fire( "unlock", "", .01 )
		end
	            ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
			end
            if GetConVarNumber("kick_effect") >= 1 then		
			    local fx 	= EffectData()
	            fx:SetStart(trace.HitPos)
	            fx:SetOrigin(trace.HitPos)
	            fx:SetNormal(trace.HitNormal)
	            util.Effect("kick_groundhit",fx)
	        end			
		elseif trace.Entity:GetClass() == "prop_dynamic" then	
			if  GetConVarNumber("kick_playersound") >= 1 then
			ply:EmitSound(GGetSound(ply:GetModel()), 50)
			end
			trace.Entity:EmitSound("player/smod_kick/foot_kickwall.wav", 100, math.random(80, 110))
			ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
	        trace.Entity:TakeDamage(damage, ply, ply)	
		            if GetConVarNumber("kick_effect") >= 1 then		
			    local fx 	= EffectData()
	            fx:SetStart(trace.HitPos)
	            fx:SetOrigin(trace.HitPos)
	            fx:SetNormal(trace.HitNormal)
	            util.Effect("kick_groundhit",fx)
	        end	
		elseif trace.Entity:IsValid() then	
		if IsValid(phys) then
		    phys:ApplyForceOffset(ply:GetAimVector():GetNormalized() * (damage * 100 * GetConVarNumber("kick_physmul")), trace.HitPos)
		end
	        trace.Entity:SetVelocity(ply:GetAimVector():GetNormalized() * (damage * 100 * GetConVarNumber("kick_physmul")))
			if  GetConVarNumber("kick_playersound") >= 1 then
			ply:EmitSound(GGetSound(ply:GetModel()), 50)
			end
			trace.Entity:EmitSound("player/smod_kick/foot_kickwall.wav", 100, math.random(80, 110))
			ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
	        trace.Entity:TakeDamage(damage, ply, ply)	
	    end 
	
	else
		if  GetConVarNumber("kick_playersound") >= 1 then
		ply:EmitSound(GGetSound(ply:GetModel()), 50, 100)
		end
	    ply:EmitSound("player/smod_kick/foot_fire.wav", 50, math.random(70, 110))
		ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
	end
    end
end

function FakeDoor(Door, attacker, amount)

        local pos = Door:GetPos()
		local ang = Door:GetAngles()
		local model = Door:GetModel()
		local skin = Door:GetSkin()
				if GetConVarNumber("kick_unlock") <= 0 then
				if  GetConVarNumber("kick_playersound") >= 1 then
				attacker:EmitSound(GGetSound(attacker:GetModel()), 50)
				end
				Door:EmitSound("physics/wood/wood_panel_impact_hard1.wav", 100, math.random(90, 110))
			else
		Door:SetNotSolid(true)
		Door:SetNoDraw(true)
		
		if Door:IsValid() then
		timer.Simple(GetConVarNumber("kick_doorrespawntime"), function()
			Door:SetNotSolid(false)
			Door:SetNoDraw(false)
			end)
			end

		local ent = ents.Create("prop_physics")
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetModel(model)
		if skin then
			ent:SetSkin(skin)
			if ent:IsValid() then
			timer.Simple(GetConVarNumber("kick_doorrespawntime"), function()
			ent:Remove()
			end)
			end
		end
		ent:Spawn()
		ent:EmitSound("physics/wood/wood_furniture_break"..math.random(1,2)..".wav", 100, math.random(70, 140))
		ent:SetVelocity(attacker:GetAimVector() * (amount * GetConVarNumber("kick_blowdoorforce")) * GetConVarNumber("kick_blowdoormulforce"))
		ent:GetPhysicsObject():ApplyForceCenter(attacker:GetAimVector() * (amount * GetConVarNumber("kick_blowdoorforce")) * GetConVarNumber("kick_blowdoormulforce"))
		
		end
end

if (SERVER) then 
	util.AddNetworkString( "Kicking" )
	
	function KickingComm(ply)
		if !ply:Alive() then return false end
		if ply.StopKick and ply.StopKick < CurTime() then
			ply:SetNWBool("Kicking",true)
			ply.KickTime = CurTime()
			ply.StopKick = ply.KickTime + GetConVarNumber("kick_time")
			timer.Simple(GetConVarNumber("kick_time"), function()
				if IsValid(ply) then
					ply:SetNWBool("Kicking",false)
				end
			end)
			if ply.SetLuaAnimation then
				ply:SetLuaAnimation("fe_g_kick")
			end
			net.Start("Kicking")
			net.WriteBool(true)
			net.Send(ply)
			timer.Simple(0.35, function()
				KickHit(ply)
			end, ply)
		end
	end
	
	concommand.Add("KickingComm",KickingComm)

	function KickPlayerStart(ply)
		ply.Kicking = false
		ply.KickTime = -1
		ply.StopKick = ply.KickTime + GetConVarNumber("kick_time")
	end
	hook.Add("PlayerSpawn","KickPlayerStart",KickPlayerStart)

	function KickPlayerDeath(ply)
		ply.Kicking = false
		ply.KickTime = -1
		ply.StopKick = ply.KickTime + GetConVarNumber("kick_time")
	end

	hook.Add("PlayerDeath","KickPlayerDeath",KickPlayerDeath)

end
