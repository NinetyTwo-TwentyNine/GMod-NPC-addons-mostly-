local NPC = { 
	Name = "Simfphys Vehicle Driver",
	Class = "npc_vehicledriver",
	KeyValues = { SquadName = "overwatch", driverminspeed = 10, drivermaxspeed = 30 },
	SpawnFlags = 256,
	Category = "Nextbot",
}
list.Set( "NPC", "snpc_vehicledriver", NPC )