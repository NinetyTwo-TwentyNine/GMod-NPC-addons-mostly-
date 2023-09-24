local function GetTrackPos( ent, div, smoother )
	local FT =  FrameTime()
	local spin_left = ent.trackspin_l and (-ent.trackspin_l / div) or 0
	local spin_right = ent.trackspin_r and (-ent.trackspin_r / div) or 0

	ent.sm_TrackDelta_L = ent.sm_TrackDelta_L and (ent.sm_TrackDelta_L + (spin_left - ent.sm_TrackDelta_L) * smoother) or 0
	ent.sm_TrackDelta_R = ent.sm_TrackDelta_R and (ent.sm_TrackDelta_R + (spin_right- ent.sm_TrackDelta_R) * smoother) or 0

	return {Left = ent.sm_TrackDelta_L,Right = ent.sm_TrackDelta_R}
end

local function UpdateTrackScrollTexture( ent )
	local id = ent:EntIndex()

	if not ent.wheel_left_mat then
		ent.wheel_left_mat = CreateMaterial(ent.TrackID .. "trackmat_" .. id .. "_left", "VertexLitGeneric", { ["$basetexture"] = ent.TrackTexture, ["$alphatest"] = "1", ["$translate"] = "[0.0 0.0 0.0]", ["Proxies"] = { ["TextureTransform"] = { ["translateVar"] = "$translate", ["centerVar"]    = "$center",["resultVar"]    = "$basetexturetransform", } } } )
	end

	if not ent.wheel_right_mat then
		ent.wheel_right_mat = CreateMaterial(ent.TrackID .. "trackmat_" .. id .. "_right", "VertexLitGeneric", { ["$basetexture"] = ent.TrackTexture, ["$alphatest"] = "1", ["$translate"] = "[0.0 0.0 0.0]", ["Proxies"] = { ["TextureTransform"] = { ["translateVar"] = "$translate", ["centerVar"]    = "$center",["resultVar"]    = "$basetexturetransform", } } } )
	end

	local TrackPos = GetTrackPos( ent, ent.TrackDiv, ent.TrackMult )

	ent.wheel_left_mat:SetVector("$translate", Vector(0,TrackPos.Left,0) )
	ent.wheel_right_mat:SetVector("$translate", Vector(0,TrackPos.Right,0) )

	ent:SetSubMaterial( ent.LeftTrackSubMatIndex or 1, "!" .. ent.TrackID .. "trackmat_" .. id .. "_left" )
	ent:SetSubMaterial( ent.RightTrackSubMatIndex or 2, "!" .. ent.TrackID .. "trackmat_" .. id .. "_right" )
end

local function UpdateTracks()
	for i, ent in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_base" ) ) do
		if ent.TrackID then
			UpdateTrackScrollTexture(ent)
		end
	end
end

hook.Add( "Think", "avx_ins1_manage_tanks", function()
	UpdateTracks()
end )

net.Receive( "avx_ins1_register_tank", function( length )
	local ent = net.ReadEntity()
	local type = net.ReadString()

	if not IsValid( ent ) then return end

	if type == "m1a1" then
		ent.TrackID = "m1a1"
		ent.TrackTexture = "models/vehicles/abrams/abrams_track"

		ent.TrackDiv = -1500
		ent.TrackMult = 0.25
		ent.LeftTrackSubMatIndex = 3
		ent.RightTrackSubMatIndex = 4
	elseif type == "t72" then
		ent.TrackID = "t72"
		ent.TrackTexture = "models/vehicles/t72/t72_track"

		ent.TrackDiv = -800
		ent.TrackMult = 0.25
		ent.LeftTrackSubMatIndex = 1
		ent.RightTrackSubMatIndex = 2
	elseif type == "bmp2" then
		ent.TrackID = "bmp2"
		ent.TrackTexture = "models/vehicles/bmp2/bmp2_track"

		ent.TrackDiv = 1500
		ent.TrackMult = 0.25
		ent.LeftTrackSubMatIndex = 2
		ent.RightTrackSubMatIndex = 3
	elseif type == "m2a3" then
		ent.TrackID = "m2a3"
		ent.TrackTexture = "models/kali/vehicles/cod4/bradley/vehicle_bradley_track_col"

		ent.TrackDiv = -260
		ent.TrackMult = 0.25
		ent.LeftTrackSubMatIndex = 2
		ent.RightTrackSubMatIndex = 3
	end
end)