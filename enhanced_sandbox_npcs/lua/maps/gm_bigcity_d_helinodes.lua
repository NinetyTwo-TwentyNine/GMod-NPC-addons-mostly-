-- Blixibon

-- Used by the Enhanced Sandbox NPCs addon

include("maps/gm_bigcity_helinodes.lua")

local v
for _, path in pairs(ESBOXNPCS_MapHeliNodes) do -- 7936

	if (string.sub(path.Targetname, 1, 23) == "esboxnpcs_helitrack_lot") then
		v = Vector(path.Origin)
		v:Add(Vector(0, 0, 11584))
		path.Origin = tostring(v)
	end

end

-- 3200
local window_path1 = { Class = "path_track", Targetname = "esboxnpcs_helitrack_window1", Origin = "-1280 -5632 -3200", Target = "esboxnpcs_helitrack_window2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" }
local window_path2 = { Class = "path_track", Targetname = "esboxnpcs_helitrack_window2", Origin = "-224 -5632 -3200", Target = "esboxnpcs_helitrack_window1", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" }
table.insert(ESBOXNPCS_MapHeliNodes, window_path1)
table.insert(ESBOXNPCS_MapHeliNodes, window_path2)
