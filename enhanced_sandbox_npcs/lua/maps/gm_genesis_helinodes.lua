-- Blixibon

-- Used by the Enhanced Sandbox NPCs addon

ESBOXNPCS_MapHeliNodes = {
	-- Spawn Area
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_spawn1", Origin = "0 -8704 -7936", Target = "esboxnpcs_helitrack_spawn2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_spawn2", Origin = "512 -10240 -7936", Target = "esboxnpcs_helitrack_spawn3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_spawn3", Origin = "1536 -10496 -7936", Target = "esboxnpcs_helitrack_spawn4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_spawn4", Origin = "2560 -10240 -7936", Target = "esboxnpcs_helitrack_spawn5", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_spawn5", Origin = "3072 -8704 -7936", Target = "esboxnpcs_helitrack_spawn6", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_spawn6", Origin = "2560 -7168 -7936", Target = "esboxnpcs_helitrack_spawn7", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_spawn7", Origin = "1536 -6912 -7936", Target = "esboxnpcs_helitrack_spawn8", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_spawn8", Origin = "512 -7168 -7936", Target = "esboxnpcs_helitrack_spawn1", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	
	-- South Fort (I know it's actually called C1)
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_southfort1", Origin = "-6784 -9472 -7680", Target = "esboxnpcs_helitrack_southfort2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_southfort2", Origin = "-7296 -6656 -7680", Target = "esboxnpcs_helitrack_southfort3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_southfort3", Origin = "-8192 -5504 -7680", Target = "esboxnpcs_helitrack_southfort4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_southfort4", Origin = "-11520 -5760 -7680", Target = "esboxnpcs_helitrack_southfort5", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_southfort5", Origin = "-12288 -7168 -7680", Target = "esboxnpcs_helitrack_southfort6", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_southfort6", Origin = "-11264 -10240 -7680", Target = "esboxnpcs_helitrack_southfort7", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_southfort7", Origin = "-9216 -11264 -7680", Target = "esboxnpcs_helitrack_southfort8", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_southfort8", Origin = "-7168 -10368 -7680", Target = "esboxnpcs_helitrack_southfort1", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	
	-- Road A
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadA1", Origin = "-1280 -6016 -7552", Target = "esboxnpcs_helitrack_roadA2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadA2", Origin = "-1280 -896 -7552", Target = "esboxnpcs_helitrack_roadA3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadA3", Origin = "-1280 2048 -7552", Target = "esboxnpcs_helitrack_roadA4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadA4", Origin = "-1280 3072 -7552", Target = "esboxnpcs_helitrack_roadA5", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadA5", Origin = "-1280 4096 -7552", Target = "esboxnpcs_helitrack_roadA6", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadA6", Origin = "-1280 6144 -7552", Target = "esboxnpcs_helitrack_roadA7", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadA7", Origin = "-1280 7936 -7552", Target = "esboxnpcs_helitrack_roadA8", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadA8", Origin = "-1280 9216 -7552", Target = "esboxnpcs_helitrack_roadA9", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadA9", Origin = "-3072 9984 -7552", Target = "esboxnpcs_helitrack_roadA10", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadA10", Origin = "-5120 10240 -7552", Target = "esboxnpcs_helitrack_roadA11", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadA11", Origin = "-8448 13568 -7552", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	
	-- Pool
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_pool1", Origin = "1536 1664 -7680", Target = "esboxnpcs_helitrack_pool2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_pool2", Origin = "3584 2816 -7680", Target = "esboxnpcs_helitrack_pool3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_pool3", Origin = "2688 5760 -7680", Target = "esboxnpcs_helitrack_pool4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_pool4", Origin = "1664 5888 -7680", Target = "esboxnpcs_helitrack_pool5", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_pool5", Origin = "384 5760 -7680", Target = "esboxnpcs_helitrack_pool6", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_pool6", Origin = "-512 2816 -7680", Target = "esboxnpcs_helitrack_pool1", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	
	-- Runway
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_runway1", Origin = "8704 512 -7808", Target = "esboxnpcs_helitrack_runway2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_runway2", Origin = "8704 3584 -7808", Target = "esboxnpcs_helitrack_runway3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_runway3", Origin = "8704 6656 -7808", Target = "esboxnpcs_helitrack_runway4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_runway4", Origin = "8704 9728 -7808", Target = "esboxnpcs_helitrack_runway5", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_runway5", Origin = "6656 9728 -7808", Target = "esboxnpcs_helitrack_runway6", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_runway6", Origin = "6656 6656 -7808", Target = "esboxnpcs_helitrack_runway7", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_runway7", Origin = "6656 3584 -7808", Target = "esboxnpcs_helitrack_runway8", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_runway8", Origin = "6656 512 -7808", Target = "esboxnpcs_helitrack_runway1", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	
	-- Road B
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB1", Origin = "1152 8704 -7680", Target = "esboxnpcs_helitrack_roadB2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB2", Origin = "2176 7936 -7552", Target = "esboxnpcs_helitrack_roadB3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB3", Origin = "4096 7808 -7552", Target = "esboxnpcs_helitrack_roadB4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB4", Origin = "4352 6912 -7552", Target = "esboxnpcs_helitrack_roadB5", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB5", Origin = "4352 5376 -7552", Target = "esboxnpcs_helitrack_roadB6", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB6", Origin = "4352 3840 -7552", Target = "esboxnpcs_helitrack_roadB7", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB7", Origin = "4352 2304 -7552", Target = "esboxnpcs_helitrack_roadB8", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB8", Origin = "4352 256 -7552", Target = "esboxnpcs_helitrack_roadB9", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB9", Origin = "4480 -1024 -7552", Target = "esboxnpcs_helitrack_roadB10", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB10", Origin = "5632 -1280 -7552", Target = "esboxnpcs_helitrack_roadB11", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB11", Origin = "6656 -1280 -7552", Target = "esboxnpcs_helitrack_roadB12", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB12", Origin = "7296 -1536 -7552", Target = "esboxnpcs_helitrack_roadB13", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB13", Origin = "7424 -2048 -7552", Target = "esboxnpcs_helitrack_roadB14", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB14", Origin = "7424 -3328 -7552", Target = "esboxnpcs_helitrack_roadB15", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB15", Origin = "7424 -4352 -7552", Target = "esboxnpcs_helitrack_roadB16", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB16", Origin = "7424 -5760 -7552", Target = "esboxnpcs_helitrack_roadB17", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB17", Origin = "9216 -7808 -7552", Target = "esboxnpcs_helitrack_roadB18", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB18", Origin = "7168 -10496 -7552", Target = "esboxnpcs_helitrack_roadB19", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB19", Origin = "2432 -10496 -7552", Target = "esboxnpcs_helitrack_roadB20", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB20", Origin = "-2048 -10496 -7552", Target = "esboxnpcs_helitrack_roadB21", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB21", Origin = "-6912 -10240 -7552", Target = "esboxnpcs_helitrack_roadB22", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB22", Origin = "-6912 -6016 -7552", Target = "esboxnpcs_helitrack_roadB23", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_roadB23", Origin = "-3328 -5888 -7552", Target = "esboxnpcs_helitrack_roadA1", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	
	-- Island
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_island1", Origin = "-11008 14336 -7552", Target = "esboxnpcs_helitrack_island2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_island2", Origin = "-13312 14464 -7552", Target = "esboxnpcs_helitrack_island3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_island3", Origin = "-14336 13312 -7552", Target = "esboxnpcs_helitrack_island4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_island4", Origin = "-13440 10624 -7552", Target = "esboxnpcs_helitrack_island5", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_island5", Origin = "-11904 9856 -7168", Target = "esboxnpcs_helitrack_island6", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_island6", Origin = "-9600 8960 -7552", Target = "esboxnpcs_helitrack_island7", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_island7", Origin = "-8704 10368 -7552", Target = "esboxnpcs_helitrack_island8", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_island8", Origin = "-8704 13952 -7552", Target = "esboxnpcs_helitrack_island1", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },

	-- Outskirts Track
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_outtrack1", Origin = "-14848 14848 -7552", Target = "esboxnpcs_helitrack_outtrack2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_outtrack2", Origin = "-14848 -14848 -7552", Target = "esboxnpcs_helitrack_outtrack3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_outtrack3", Origin = "14848 -14848 -7552", Target = "esboxnpcs_helitrack_outtrack4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_outtrack4", Origin = "14848 14848 -7552", Target = "esboxnpcs_helitrack_outtrack1", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	
	-- Circuit
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_circuit1", Origin = "-5120 1792 -7680", Target = "esboxnpcs_helitrack_circuit2", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_circuit2", Origin = "-9216 1792 -7680", Target = "esboxnpcs_helitrack_circuit3", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_circuit3", Origin = "-9088 3072 -7680", Target = "esboxnpcs_helitrack_circuit4", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_circuit4", Origin = "-5504 6912 -7680", Target = "esboxnpcs_helitrack_circuit5", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_circuit5", Origin = "-5248 8192 -7680", Target = "esboxnpcs_helitrack_circuit6", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_circuit6", Origin = "-3456 8192 -7680", Target = "esboxnpcs_helitrack_circuit7", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_circuit7", Origin = "-3072 7168 -7680", Target = "esboxnpcs_helitrack_circuit8", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_circuit8", Origin = "-2944 6016 -7680", Target = "esboxnpcs_helitrack_circuit9", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_circuit9", Origin = "-4480 4992 -7680", Target = "esboxnpcs_helitrack_circuit10", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_circuit10", Origin = "-3200 3712 -7680", Target = "esboxnpcs_helitrack_circuit11", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	{ Class = "path_track", Targetname = "esboxnpcs_helitrack_circuit11", Origin = "-3200 2048 -7680", Target = "esboxnpcs_helitrack_circuit1", OrientationType = 0, OnPass = "esboxnpcs_helitrack_autofly,RunCode,0,-1" },
	
	{ Class = "lua_run", Targetname = "esboxnpcs_helitrack_autofly", Origin = "0 0 1024", Code = "ESBOXNPCS_InternalPathHandler(ACTIVATOR, CALLER)" },
}

