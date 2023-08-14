-- Blixibon

-- Used by the Enhanced Sandbox NPCs addon

include("maps/gm_genesis_helinodes.lua")

local v
for _, path in pairs(ESBOXNPCS_MapHeliNodes) do -- 7936

	v = Vector(path.Origin)
	v:Add(Vector(0, 0, 9472))
	path.Origin = tostring(v)

end
