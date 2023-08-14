local Vehicle = { 
	Name = "Combine APC",
	Class = "prop_vehicle_apc",
        Model = "models/combine_apc.mdl",
	KeyValues = { VehicleScript = "scripts/vehicles/apc_npc.txt" },
	Category = "Half-Life 2",
}
list.Set( "Vehicles", Vehicle.Class, Vehicle )

local NPC = { 
	Name = "Combine APC Driver",
	Class = "npc_apcdriver",
	KeyValues = { SquadName = "overwatch", driverminspeed = 10, drivermaxspeed = 30 },
	Category = "Combine",
}
list.Set( "NPC", NPC.Class, NPC )

local NPC = {   Name = "Combine Leader",
                Class = "npc_combine_s",
                Model = "models/combine_leader.mdl",
                Health = 90,
		KeyValues = { SquadName = "overwatch", tacticalvariant = 2, Numgrenades = 0 },
                Weapons = { "swep_a35", "swep_detached_emplacement_gun" },
                Category = "Combine"
}
list.Set( "NPC", "npc_scombinel", NPC )


local NPC = {   Name = "Combine Marksman",
                Class = "npc_combine_s",
                Model = "models/combine_sniper.mdl",
		SpawnFlags = 256,
		KeyValues = { SquadName = "overwatch", tacticalvariant = 0, Numgrenades = 0 },
                Weapons = { "swep_hl2s_sniper" }, 
                Category = "Combine"
}
list.Set( "NPC", "npc_scombinem", NPC )


local NPC = {   Name = "Metro Police Recruit",
                Class = "npc_metropolice",
		SpawnFlags = 131072 + 524288,
		KeyValues = { SquadName = "overwatch" },
                Weapons = { "weapon_stunstick", "weapon_pistol", "weapon_smg1" },
                Category = "Combine"
}
list.Set( "NPC", "npc_smetropolicer", NPC )


local NPC = {   Name = "Metro Police Leader",
                Class = "npc_metropolice",
                Health = 54,
		SpawnFlags = 16 + 33554432,
		KeyValues = { SquadName = "overwatch" },
                Weapons = { "weapon_smg1", "weapon_annabelle", "swep_npcrocketlauncher" }, 
                Category = "Combine"
}
list.Set( "NPC", "npc_smetropolicel", NPC )