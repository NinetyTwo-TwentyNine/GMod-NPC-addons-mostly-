SIMFPHYS_AI_WeaponFuncs = {}

local initializeWeaponSystem = function(vehicle, seatsAmount)
	if !isstring(vehicle) || !isnumber(seatsAmount) then return end

	SIMFPHYS_AI_WeaponFuncs[vehicle] = {}
	for i = 0,(seatsAmount-1) do
		SIMFPHYS_AI_WeaponFuncs[vehicle][i] = {}
	end
end


local genericBurstFiring = function(scaler, minimum, phaseOffset)
	return math.cos(CurTime() * scaler + phaseOffset) > minimum
end
local genericAntiArmourFiring = function(attacker, los_ent)
	if !IsValid(los_ent) then return false end
	return (simfphys.IdentifyVehicleTarget(attacker, los_ent) != los_ent)
end


// ============================= Ratmobile =============================

initializeWeaponSystem("sim_fphys_ratmobile", 1)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_ratmobile"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337) && !attacker:KeyDown(IN_ATTACK2)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_ratmobile"][0][2] = function(attacker, los_ent)
	return genericBurstFiring(0.8, -0.9, attacker:EntIndex() * -228) && !attacker:KeyDown(IN_ATTACK)
end

// ============================= Tau-cannon =============================

initializeWeaponSystem("sim_fphys_jeep_armed", 1)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_jeep_armed"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337) && !attacker:KeyDown(IN_ATTACK2)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_jeep_armed"][0][2] = function(attacker, los_ent)
	return genericBurstFiring(0.8, -0.9, attacker:EntIndex() * -228) && !attacker:KeyDown(IN_ATTACK)
end

// ============================= Airboat Gun =============================

initializeWeaponSystem("sim_fphys_jeep_armed2", 1)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_jeep_armed2"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(1.6, -0.9, attacker:EntIndex() * -1337)
end

// ============================= Combine APC =============================

initializeWeaponSystem("sim_fphys_combineapc_armed", 1)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_combineapc_armed"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337) && (attacker:EyePos():Distance(los_ent:GetPos()) <= 1250)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_combineapc_armed"][0][2] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337) && (attacker:EyePos():Distance(los_ent:GetPos()) > 1250)
end

// ============================= Sherman =============================

initializeWeaponSystem("sim_fphys_tank2", 2)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank2"][0][1] = function(attacker, los_ent)
	return genericAntiArmourFiring(attacker, los_ent) && genericBurstFiring(0.8, -0.9, attacker:EntIndex() * -228)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank2"][0][2] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank2"][1][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end

// ============================= Tiger =============================

initializeWeaponSystem("sim_fphys_tank", 2)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank"][0][1] = function(attacker, los_ent)
	return genericAntiArmourFiring(attacker, los_ent) && genericBurstFiring(0.8, -0.9, attacker:EntIndex() * -228)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank"][0][2] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank"][1][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end

// ============================= HMMWV =============================

initializeWeaponSystem("avx_hmmwv", 1)

SIMFPHYS_AI_WeaponFuncs["avx_hmmwv"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end

// ============================= BRDM =============================

initializeWeaponSystem("sim_fphys_conscriptapc_armed", 1)
initializeWeaponSystem("sim_fphys_conscriptapc_armed2", 1)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_conscriptapc_armed"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_conscriptapc_armed2"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end

// ============================= LAV =============================

initializeWeaponSystem("sim_fphys_lav25_armed", 1)
initializeWeaponSystem("sim_fphys_lav-c2_armed", 1)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_lav25_armed"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(1.6, -0.9, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_lav-c2_armed"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(0.8, -0.9, attacker:EntIndex() * -1337)
end

// ============================= BMP-2 =============================

initializeWeaponSystem("avx_bmp2", 1)

SIMFPHYS_AI_WeaponFuncs["avx_bmp2"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337) && !attacker:KeyDown(IN_ATTACK2)
end
SIMFPHYS_AI_WeaponFuncs["avx_bmp2"][0][2] = function(attacker, los_ent)
	return genericAntiArmourFiring(attacker, los_ent) && genericBurstFiring(0.8, -0.9, attacker:EntIndex() * -228) && !attacker:KeyDown(IN_ATTACK)
end

// ============================= FV510 Warrior =============================

initializeWeaponSystem("sim_fphys_fv510_armed", 1)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_fv510_armed"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(1.6, -0.9, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_fv510_armed"][0][2] = function(attacker, los_ent)
	return genericAntiArmourFiring(attacker, los_ent)
end

// ============================= SPZ Puma =============================

initializeWeaponSystem("sim_fphys_spz_puma_armed", 1)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_spz_puma_armed"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_spz_puma_armed"][0][2] = function(attacker, los_ent)
	return genericAntiArmourFiring(attacker, los_ent) && genericBurstFiring(3.75, 0.9, attacker:EntIndex() * -228)
end

// ============================= M2A3 Bradley =============================

initializeWeaponSystem("avx_m2a3", 1)

SIMFPHYS_AI_WeaponFuncs["avx_m2a3"][0][1] = function(attacker, los_ent)
	return genericBurstFiring(1.6, -0.9, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["avx_m2a3"][0][2] = function(attacker, los_ent)
	return genericAntiArmourFiring(attacker, los_ent) && genericBurstFiring(3.75, 0.9, attacker:EntIndex() * -228)
end

// ============================= T-72 =============================

initializeWeaponSystem("avx_t72", 2)

SIMFPHYS_AI_WeaponFuncs["avx_t72"][0][1] = function(attacker, los_ent)
	return genericAntiArmourFiring(attacker, los_ent) && genericBurstFiring(0.8, -0.9, attacker:EntIndex() * -228)
end
SIMFPHYS_AI_WeaponFuncs["avx_t72"][0][2] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["avx_t72"][1][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end

// ============================= T-90M =============================

initializeWeaponSystem("sim_fphys_tank4", 2)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank4"][0][1] = function(attacker, los_ent)
	return genericAntiArmourFiring(attacker, los_ent) && genericBurstFiring(0.8, -0.9, attacker:EntIndex() * -228)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank4"][0][2] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank4"][1][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end

// ============================= Challenger Mk.III =============================

initializeWeaponSystem("sim_fphys_tank5", 2)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank5"][0][1] = function(attacker, los_ent)
	return genericAntiArmourFiring(attacker, los_ent) && genericBurstFiring(0.8, -0.9, attacker:EntIndex() * -228)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank5"][0][2] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank5"][1][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end

// ============================= Leopard 2A7 =============================

initializeWeaponSystem("sim_fphys_tank3", 2)

SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank3"][0][1] = function(attacker, los_ent)
	return genericAntiArmourFiring(attacker, los_ent) && genericBurstFiring(0.8, -0.9, attacker:EntIndex() * -228)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank3"][0][2] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["sim_fphys_tank3"][1][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end

// ============================= M1A1 Abrams =============================

initializeWeaponSystem("avx_m1a1", 2)

SIMFPHYS_AI_WeaponFuncs["avx_m1a1"][0][1] = function(attacker, los_ent)
	return genericAntiArmourFiring(attacker, los_ent) && genericBurstFiring(0.8, -0.9, attacker:EntIndex() * -228)
end
SIMFPHYS_AI_WeaponFuncs["avx_m1a1"][0][2] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end
SIMFPHYS_AI_WeaponFuncs["avx_m1a1"][1][1] = function(attacker, los_ent)
	return genericBurstFiring(3.75, -0.25, attacker:EntIndex() * -1337)
end