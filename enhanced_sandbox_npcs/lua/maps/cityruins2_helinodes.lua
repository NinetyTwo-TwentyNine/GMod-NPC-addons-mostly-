-- Blixibon

-- Used by the Enhanced Sandbox NPCs addon

ESBOXNPCS_MapHeliNodes = {
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main1", Origin = "2880 -2048 256", Target = "esboxnpcs_helitrack_main2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main2", Origin = "512 -2048 256", Target = "esboxnpcs_helitrack_main3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main3", Origin = "-1728 -2240 512", Target = "esboxnpcs_helitrack_main4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main4", Origin = "-1728 -448 320", Target = "esboxnpcs_helitrack_main5", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main5", Origin = "-128 -512 128", Target = "esboxnpcs_helitrack_main6", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main6", Origin = "1920 -512 192", Target = "esboxnpcs_helitrack_main7", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main7", Origin = "3072 -640 320", Target = "esboxnpcs_helitrack_main8", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main8", Origin = "3136 192 512", Target = "esboxnpcs_helitrack_main9", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main9", Origin = "2880 960 256", Target = "esboxnpcs_helitrack_main10", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main10", Origin = "1344 960 256", Target = "esboxnpcs_helitrack_main11", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main11", Origin = "-64 960 256", Target = "esboxnpcs_helitrack_main12", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main12", Origin = "-1728 960 256", Target = "esboxnpcs_helitrack_main13", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main13", Origin = "-3200 960 256", Target = "esboxnpcs_helitrack_main14", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main14", Origin = "-4096 960 256", Target = "esboxnpcs_helitrack_main15", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main15", Origin = "-4992 960 256", Target = "esboxnpcs_helitrack_main16", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main16", Origin = "-4992 -896 256", Target = "esboxnpcs_helitrack_main17", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main17", Origin = "-4416 -1664 256", Target = "esboxnpcs_helitrack_main18", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main18", Origin = "-3136 -1664 256", Target = "esboxnpcs_helitrack_main19", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_main19", Origin = "-3136 -512 256", Target = "", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_backstreet1", Origin = "4096 3072 192", Target = "esboxnpcs_helitrack_backstreet2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_backstreet2", Origin = "2816 2880 192", Target = "esboxnpcs_helitrack_backstreet3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_backstreet3", Origin = "1152 2880 192", Target = "esboxnpcs_helitrack_backstreet4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_backstreet4", Origin = "0 2944 192", Target = "esboxnpcs_helitrack_backstreet5", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_backstreet5", Origin = "-1792 3072 192", Target = "", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	
	{ Class = "lua_run", Targetname = "esboxnpcs_helitrack_autofly", Origin = "0 0 1024", Code = "ESBOXNPCS_InternalPathHandler(ACTIVATOR, CALLER)" },
}

