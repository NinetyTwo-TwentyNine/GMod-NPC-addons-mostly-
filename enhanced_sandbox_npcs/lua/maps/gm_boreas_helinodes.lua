-- Blixibon

-- Used by the Enhanced Sandbox NPCs addon

include("maps/gm_boreas(base)_helinodes.lua")

local v
for _, path in pairs(ESBOXNPCS_MapHeliNodes) do -- 7936

	v = Vector(path.Origin)
	v:Add(Vector(0, 0, 1536))
	path.Origin = tostring(v)

end
