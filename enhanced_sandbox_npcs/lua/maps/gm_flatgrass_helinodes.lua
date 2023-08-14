-- Blixibon

-- Used by the Enhanced Sandbox NPCs addon

ESBOXNPCS_MapHeliNodes = {
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main1", Origin = "0 4096 -11776", Target = "esboxnpcs_helitrack_main2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main2", Origin = "3072 3072 -11776", Target = "esboxnpcs_helitrack_main3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main3", Origin = "4096 0 -11776", Target = "esboxnpcs_helitrack_main4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main4", Origin = "3072 -3072 -11776", Target = "esboxnpcs_helitrack_main5", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main5", Origin = "0 -4096 -11776", Target = "esboxnpcs_helitrack_main6", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main6", Origin = "-3072 -3072 -11776", Target = "esboxnpcs_helitrack_main7", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main7", Origin = "-4096 0 -11776", Target = "esboxnpcs_helitrack_main8", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main8", Origin = "-3072 3072 -11776", Target = "esboxnpcs_helitrack_main1", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	
	{ Class = "lua_run", Targetname = "esboxnpcs_helitrack_autofly", Origin = "0 0 1024", Code = "ESBOXNPCS_InternalPathHandler(ACTIVATOR, CALLER)" },
}

