-- Blixibon

-- Used by the Enhanced Sandbox NPCs addon

include("maps/gm_construct_helinodes.lua")

local v
for _, path in pairs(ESBOXNPCS_MapHeliNodes) do -- 7936

	v = Vector(path.Origin)
	v:Add(Vector(1024, -1024, -8704))
	path.Origin = tostring(v)

end
