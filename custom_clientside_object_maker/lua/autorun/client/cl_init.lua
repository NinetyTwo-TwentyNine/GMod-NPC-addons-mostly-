if engine.ActiveGamemode() == "MarumRTS" or engine.ActiveGamemode() == "sandbox" then

MRTSMMPlasticMaterial = Material( "models/debug/debugwhite" ) 

hook.Add( "PostDrawOpaqueRenderables", "BlockCatalogueRender", function()
	if (LocalPlayer():GetTool() != nil) then
		if (string.StartWith( LocalPlayer():GetTool().Mode, "clientside_weird_model_maker")) then
			
			if (MRTSMMSizeChanged+1.5 > CurTime()) then
				render.SetMaterial(MRTSMMPlasticMaterial)
				render.DrawSphere( MRTSMMPosition+Vector(0,0,MRTSMMSize), MRTSMMSize, 16, 16, Color( 255, 255, 255 ) )
			end
		end
	end
end )

hook.Add("PostDrawTranslucentRenderables", "MRTSMMDraw", function()
	MRTSMMDraw()
end)

hook.Add("Think", "MRTSMMThink", function()
	if (#MRTSMMModelData > 0) then
		MRTSMMAngle = MRTSMMAngle+MRTSMMRotation*engine.TickInterval()
		MRTSMMClientDirectionAngle = Angle(0,MRTSMMAngle,0)

		if (MRTSMMPointAround) then
			MRTSMMClientHorizontalAngle = MRTSMMClientDirectionAngle+Angle(0,math.sin(CurTime()*2)*50, 0)
			MRTSMMClientVerticalAngle = Angle(-(1-math.cos(CurTime()*2))*30, 0,0)
			//MRTSMMaimUntil = CurTime()+math.sin(CurTime())
			MRTSMMaimUntil = CurTime()+1
		else
			MRTSMMaimUntil = 0
		end
	end
end)

MRTSMMModelData = {}
MRTSMMModels = {}
MRTSMMPosition = Vector(0,0,0)
MRTSMMClientDirectionAngle = Angle(0,0,0)
MRTSMMClientHorizontalAngle = Angle(0,0,0)
MRTSMMClientVerticalAngle = Angle(0,0,0)
MRTSMMaimUntil = CurTime()
MRTSMManim = CurTime()
MRTSMMSizeChanged = CurTime()
MRTSMMSize = 10
MRTSMMWindup = 0.2
MRTSMMPointAround = false
MRTSMMMoving = false
MRTSMMRotation = 0
MRTSMMAngle = 0
MRTSMMJson = [[
[
	{
		"path": "models/planets/luna.mdl",
		"angle": "{0 45 45}",
		"boneAngle": "{45 0 0}",
		"position": "[0 0 0]",
		"offset": "[0 15.2079 0]",
		"horizontalAim": true,
		"verticalAim": false,
		"colors": {
			"r": 255.0,
			"b": 255.0,
			"a": 255.0,
			"g": 255.0
		},
		"keepMaterial": true,
		"scale": 1000000000,
		"boneScale": 0.000000001,
		"fire_animation":[
			{
				"time": 0,
				"offset": "[0 0 0]",
				"angle": "{0 0 0}",
				"curve": "linear"
			}
		]
	}
]

]]

MRTSMMColor = Color(255,0 ,0)

function MRTSMMPlaceModel(pos)
	MRTSMMPosition = pos
	MRTSMMDraw()
end

function MRTSMMDelete()
	for k, v in pairs(MRTSMMModels) do
		v:Remove()
	end
	MRTSMMModels = {}
	MRTSMMModelData = {}
end

function MRTSMMUpdate()
	MRTSMMJsonData = util.JSONToTable(MRTSMMJson)
	for k, v in pairs(MRTSMMModels) do
		v:Remove()
	end
	MRTSMMModels = {}

	MRTSMMModels, MRTSMMModelData = MRTSMMSetCliensideModels(1, MRTSMMPosition, MRTSMMJsonData, false)
	MRTSMMDefaults(MRTSMMModelData)
end

function MRTSMMDraw()
	if (#MRTSMMModels > 0) then
		local movement = 0
		if (MRTSMMMoving) then
			movement = CurTime()*1000
		end
		MRTSMMDrawUnit(MRTSMMModels, MRTSMMModelData, MRTSMMPosition+Vector(0,0,MRTSMMSize), MRTSMMClientDirectionAngle, MRTSMManim, MRTSMManim, MRTSMMaimUntil, movement, MRTSMMClientHorizontalAngle, MRTSMMClientVerticalAngle, 0)
	end
end

function MRTS_AnimationCurves(curve, x)
		// Forward
	if (curve == "linear") then
		return MRTS_AnimationCurve_Linear(x);
	elseif (curve == "inverse_linear") then
		return MRTS_AnimationCurve_Inverse(x);
	elseif (curve == "pingpong") then
		return MRTS_AnimationCurve_Pingpong(x)
	elseif (curve == "dampen") then
		return MRTS_AnimationCurve_Dampen(x)
		// Looping
	elseif (curve == "sine") then // sine
		return MRTS_AnimationCurve_Sine(x)
	elseif (curve == "abssine") then // absolute sine
		return MRTS_AnimationCurve_AbsSine(x)
	elseif (curve == "possine") then // positive sine
		return MRTS_AnimationCurve_PosSine(x)
	end
end

function MRTS_AnimationCurve_Linear(x)
	return x;
end

function MRTS_AnimationCurve_Inverse(x)
	return -x;
end

function MRTS_AnimationCurve_Pingpong(x)
	if (x < 0.5) then
		return x*2
	else
		return (2-x*2)
	end
end

function MRTS_AnimationCurve_Dampen(x)
	local ox = x-1
	local ox2 = ox*ox
	local ox4 = ox2*ox2
	local ox16 = ox4*ox4
	local ox15 = ox16/ox
	return (ox15+ox2)*1.575
end

function MRTS_AnimationCurve_Sine(x)
	return math.sin(x*math.pi*2);
end

function MRTS_AnimationCurve_AbsSine(x)
	return math.abs(math.sin(x*math.pi*2));
end

function MRTS_AnimationCurve_PosSine(x)
	return math.cos(x*math.pi*2)/2+0.5;
end

ColorMaterial = Material( "color" )
MRTSMaterialRing = Material( "effects/select_ring" )
MRTSMaterialFlare = Material( "effects/yellowflare" )


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
/////////////////// Funciones que hay que reemplazar //////////////////////////
/////////////////// (Y cambiar MRTS por MRTSMM) ///////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

function MRTSMMSetCliensideModels(_team, position, data, ghost)
	//print("[ent_mrts_base cl_init 24] Setting clientside models")
	local tc = MRTSMMColor
	local c = Color(tc.r, tc.g, tc.b)
	local CSModels = {}
	local CSModelData = {}
	for k, v in pairs(data) do
		CSModels[k] = ClientsideModel( v.path )
		CSModels[k]:SetNoDraw(true)
		CSModelData[k] = table.Copy( v )

		if (CSModelData[k].teamColor == true) then
			local o = CSModelData[k].colors;
			local tint = CSModelData[k].tint or 1
			if (CSModelData[k].tint != nil) then
				tint = CSModelData[k].tint
				c.r = tc.r*tint+o.r*(1-tint)
				c.g = tc.g*tint+o.g*(1-tint)
				c.b = tc.b*tint+o.b*(1-tint)
			end
			CSModelData[k].colors = Color(c.r, c.g, c.b)
		end
		if (not v.keepMaterial) then
			CSModels[k]:SetMaterial("models/debug/debugwhite")
		end
		if (ghost) then
			CSModelData[k].colors.a = 0.6
		end
		if CSModels[k]:GetBoneCount() == 1 then
			if CSModelData[k].boneScale then
				CSModels[k]:ManipulateBoneScale(0, Vector(CSModelData[k].boneScale, CSModelData[k].boneScale, CSModelData[k].boneScale))
			end

			if CSModelData[k].boneAngle then
				CSModels[k]:ManipulateBoneAngles(0, CSModelData[k].boneAngle)
			end
		end
		CSModels[k]:SetModelScale(CSModelData[k].scale or 1)
		CSModels[k]:SetPos(position)
		CSModels[k]:SetColor(CSModelData[k].colors)
	end

	return CSModels, CSModelData
end

function MRTSMMDefaults(models)
	for kk, vv in pairs(models) do
		vv.scale = vv.scale or 1;
		vv.boneScale = vv.boneScale or 1;
		vv.horizontalAim = vv.horizontalAim or false;
		vv.verticalAim = vv.verticalAim or false;
		vv.position = vv.position or Vector(0,0,0);
		vv.offset = vv.offset or Vector(0,0,0);
		vv.boneAngle = vv.boneAngle or Angle(0,0,0);
		vv.angle = vv.angle or Angle(0,0,0);
		vv.colors = vv.colors or {r=255, g=255, b=255, a=255};
		vv.teamColor = vv.teamColor or false;
		vv.keepMaterial = vv.keepMaterial or false;
		if (vv.fire_animation != nil) then
			for kkk, vvv in pairs(vv.fire_animation) do
				vvv.time = vvv.time or 1;
				vvv.boneAngle = vvv.boneAngle or Angle(0,0,0);
				vvv.offset = vvv.offset or Vector(0,0,0);
				vvv.angle = vvv.angle or Angle(0,0,0);
				vvv.position = vvv.position or Vector(0,0,0);
			end
		end
		if (vv.move_animation != nil) then
			for kkk, vvv in pairs(vv.move_animation) do
				vvv.speed = vvv.speed or 1;
				vvv.boneAngle = vvv.boneAngle or Angle(0,0,0);
				vvv.offset = vvv.offset or Vector(0,0,0);
				vvv.angle = vvv.angle or Angle(0,0,0);
				vvv.position = vvv.position or Vector(0,0,0);
				vvv.delay = vvv.delay or 0;
			end
		end
		if (vv.windup_animation != nil) then
			for kkk, vvv in pairs(vv.windup_animation) do
				vvv.time = vvv.time or 1;
				vvv.boneAngle = vvv.boneAngle or Angle(0,0,0);
				vvv.offset = vvv.offset or Vector(0,0,0);
				vvv.angle = vvv.angle or Angle(0,0,0);
				vvv.position = vvv.position or Vector(0,0,0);
			end
		end
	end
end

function MRTSMMDrawUnit(models, modelData, position, directionAngle, lastAttack, nextAttack, aimUntil, movement, targetHorizontalAngle, targetVerticalAngle, lastHit)
	lastHit = lastHit or 0
	lastAttack = lastAttack or 0
	nextAttack = nextAttack or 0
	movement = movement or 0
	aimUntil = aimUntil or 0

	for k, v in pairs(models) do

		// Animation
		local fire_animation = modelData[k].fire_animation
		local windup_animation = modelData[k].windup_animation
		local move_animation = modelData[k].move_animation
		local animBoneRotation = Angle(0,0,0)
		local animPosition = Vector(0,0,0)
		local animRotation = Angle(0,0,0)
		local animOffset = Vector(0,0,0)
		if (fire_animation != nil) then
			if (lastAttack < CurTime()) then
				for kk, vv in pairs(fire_animation) do
					local animTime = (CurTime()-lastAttack)/vv.time
					local animPercentage = MRTS_AnimationCurves(vv.curve,animTime)
					if (animTime < 1) then
						animBoneRotation = animBoneRotation+vv.boneAngle*animPercentage
						animPosition = animPosition+vv.position*animPercentage
						animRotation = animRotation+vv.angle*animPercentage
						animOffset = animOffset+vv.offset*animPercentage
					end
				end
			end
		end

		if (windup_animation != nil) then
			for kk, vv in pairs(windup_animation) do
				local animTime = (CurTime()-nextAttack+vv.time)/vv.time
				local animPercentage = MRTS_AnimationCurves(vv.curve,animTime)
				if (animTime > 0 and animTime < 1) then
					animBoneRotation = animBoneRotation+vv.boneAngle*animPercentage
					animPosition = animPosition+vv.position*animPercentage
					animRotation = animRotation+vv.angle*animPercentage
					animOffset = animOffset+vv.offset*animPercentage
				end
			end
		end

		if (movement > 0) then
			if (move_animation != nil) then
				for kk, vv in pairs(move_animation) do
					local animTime = ((movement-vv.delay*1000)*vv.speed/1000)%1
					local animPercentage = MRTS_AnimationCurves(vv.curve,animTime)
					if (animTime < 1) then
						animBoneRotation = animBoneRotation+vv.boneAngle*animPercentage
						animPosition = animPosition+vv.position*animPercentage
						animRotation = animRotation+vv.angle*animPercentage
						animOffset = animOffset+vv.offset*animPercentage
					end
				end
			end
		end

		// Drawing
		local boneang = modelData[k].boneAngle+animBoneRotation
		local pos = modelData[k].position+animPosition
		local ang = modelData[k].angle+animRotation
		local offset = modelData[k].offset+animOffset

		if v:GetBoneCount() == 1 then
			v:ManipulateBoneAngles( 0, boneang )
		end
		v:SetAngles(ang+directionAngle)

		if (aimUntil > CurTime()) then
			local aimAngle = ang
			if (modelData[k].horizontalAim) then
				aimAngle = aimAngle+targetHorizontalAngle
			end

			if (modelData[k].verticalAim) then
				aimAngle = aimAngle+targetVerticalAngle
			end

			if (modelData[k].horizontalAim or modelData[k].verticalAim) then
				v:SetAngles(aimAngle)
			end
		else
			ang = ang+directionAngle
		end

		if v:GetBoneCount() == 1 then
			v:ManipulateBonePosition( 0, offset )
		end
		v:SetPos(position+pos)

		local c = modelData[k].colors
		render.SetColorModulation( c.r/255, c.g/255, c.b/255 )
		if (CurTime()-lastHit < 0.1) then
			render.SetColorModulation( c.r/255+0.3, c.g/255+0.3, c.b/255+0.3 )
		end
		render.SetBlend( c.a )
		v:DrawModel()
		render.SetBlend( 1 )
		render.SetColorModulation( 1,1,1 )
	end
end

end