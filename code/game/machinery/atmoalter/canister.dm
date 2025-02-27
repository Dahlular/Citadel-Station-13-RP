#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "yellow"
	density = 1
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE
	var/health = 100.0
	w_class = ITEMSIZE_HUGE

	layer = TABLE_LAYER	// Above catwalks, hopefully below other things

	///Is the valve open?
	var/valve_open = FALSE
	///Used to log opening and closing of the valve, available on VV
	var/release_log = ""
	///How much the canister should be filled (recommended from 0 to 1)
	//var/filled = 0.5
	///Stores the path of the gas for mapped canisters
	//var/gas_type
	///Player controlled var that set the release pressure of the canister
	var/release_pressure = ONE_ATMOSPHERE
	///Maximum pressure allowed for release_pressure var
	var/can_max_release_pressure = (ONE_ATMOSPHERE * 10)
	///Minimum pressure allower for release_pressure var
	var/can_min_release_pressure = (ONE_ATMOSPHERE * 0.1)
	///Max amount of heat allowed inside of the canister before it starts to melt (different tiers have different limits)
	var/heat_limit = 5000
	///Max amount of pressure allowed inside of the canister before it starts to break (different tiers have different limits)
	var/pressure_limit = 46000

	var/release_flow_rate = ATMOS_DEFAULT_VOLUME_PUMP //in L/s
	var/canister_color = "yellow"
	var/can_label = TRUE
	start_pressure = 45 * ONE_ATMOSPHERE
	pressure_resistance = 7 * ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = USE_POWER_OFF
	var/update_flag = 0

/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "Canister: \[N2O\]"
	icon_state = "redws"
	canister_color = "redws"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red"
	canister_color = "red"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
	canister_color = "blue"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/oxygen/prechilled
	name = "Canister: \[O2 (Cryo)\]"

/obj/machinery/portable_atmospherics/canister/phoron
	name = "Canister \[Phoron\]"
	icon_state = "orange"
	canister_color = "orange"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black"
	canister_color = "black"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "grey"
	canister_color = "grey"
	can_label = 0

/obj/machinery/portable_atmospherics/canister/air/airlock
	start_pressure = 3 * ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/canister/empty/
	start_pressure = 0
	can_label = 1

/obj/machinery/portable_atmospherics/canister/empty/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
	canister_color = "blue"
/obj/machinery/portable_atmospherics/canister/empty/phoron
	name = "Canister \[Phoron\]"
	icon_state = "orange"
	canister_color = "orange"
/obj/machinery/portable_atmospherics/canister/empty/nitrogen
	name = "Canister \[N2\]"
	icon_state = "red"
	canister_color = "red"
/obj/machinery/portable_atmospherics/canister/empty/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black"
	canister_color = "black"
/obj/machinery/portable_atmospherics/canister/empty/nitrous_oxide
	name = "Canister \[N2O\]"
	icon_state = "redws"
	canister_color = "redws"

/obj/machinery/portable_atmospherics/canister/helium
	name = "Canister \[Helium\]"

/obj/machinery/portable_atmospherics/canister/carbon_monoxide
	name = "Canister \[Carbon Monoxide\]"

/obj/machinery/portable_atmospherics/canister/methyl_bromide
	name = "Canister \[Methyl Bromide\]"

/obj/machinery/portable_atmospherics/canister/nitrodioxide
	name = "Canister \[Nitrogen Dioxide\]"

/obj/machinery/portable_atmospherics/canister/nitricoxide
	name = "Canister \[Nitric Oxide\]"

/obj/machinery/portable_atmospherics/canister/methane
	name = "Canister \[Methane\]"

/obj/machinery/portable_atmospherics/canister/argon
	name = "Canister \[Argon\]"

/obj/machinery/portable_atmospherics/canister/krypton
	name = "Canister \[Krypton\]"

/obj/machinery/portable_atmospherics/canister/neon
	name = "Canister \[Neon\]"

/obj/machinery/portable_atmospherics/canister/ammonia
	name = "Canister \[Ammonia\]"

/obj/machinery/portable_atmospherics/canister/xenon
	name = "Canister \[Xenon\]"

/obj/machinery/portable_atmospherics/canister/chlorine
	name = "Canister \[Chlorine\]"

/obj/machinery/portable_atmospherics/canister/sulfur_dioxide
	name = "Canister \[Sulfur Dioxide\]"

/obj/machinery/portable_atmospherics/canister/hydrogen
	name = "Canister \[Hydrogen\]"

/obj/machinery/portable_atmospherics/canister/tritium
	name = "Canister \[Tritium\]"

/obj/machinery/portable_atmospherics/canister/deuterium
	name = "Canister \[Deuterium\]"



/obj/machinery/portable_atmospherics/canister/proc/check_change()
	var/old_flag = update_flag
	update_flag = 0
	if(holding)
		update_flag |= 1
	if(connected_port)
		update_flag |= 2

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < 10)
		update_flag |= 4
	else if(tank_pressure < ONE_ATMOSPHERE)
		update_flag |= 8
	else if(tank_pressure < 15*ONE_ATMOSPHERE)
		update_flag |= 16
	else
		update_flag |= 32

	if(update_flag == old_flag)
		return 1
	else
		return 0

/obj/machinery/portable_atmospherics/canister/update_icon()
/*
update_flag
1 = holding
2 = connected_port
4 = tank_pressure < 10
8 = tank_pressure < ONE_ATMOS
16 = tank_pressure < 15*ONE_ATMOS
32 = tank_pressure go boom.
*/

	if (destroyed)
		cut_overlays()
		icon_state = "[canister_color]-1"
		return

	if(icon_state != "[canister_color]")
		icon_state = "[canister_color]"

	if(check_change()) //Returns 1 if no change needed to icons.
		return

	cut_overlays()
	var/list/overlays_to_add = list()

	if(update_flag & 1)
		overlays_to_add += "can-open"
	if(update_flag & 2)
		overlays_to_add += "can-connector"
	if(update_flag & 4)
		overlays_to_add += "can-o0"
	if(update_flag & 8)
		overlays_to_add += "can-o1"
	else if(update_flag & 16)
		overlays_to_add += "can-o2"
	else if(update_flag & 32)
		overlays_to_add += "can-o3"

	add_overlay(overlays_to_add)

	return

/obj/machinery/portable_atmospherics/canister/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		health -= 5
		healthcheck()

/obj/machinery/portable_atmospherics/canister/proc/healthcheck()
	if(destroyed)
		return 1

	if (src.health <= 10)
		var/atom/location = src.loc
		location.assume_air(air_contents)

		src.destroyed = 1
		playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
		src.density = 0
		update_icon()

		if (src.holding)
			src.holding.loc = src.loc
			src.holding = null

		return 1
	else
		return 1

/obj/machinery/portable_atmospherics/canister/process(delta_time)
	if (destroyed)
		return

	..()

	if(valve_open)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()

		var/env_pressure = environment.return_pressure()
		var/pressure_delta = release_pressure - env_pressure

		if((air_contents.temperature > 0) && (pressure_delta > 0))
			var/transfer_moles = calculate_transfer_moles(air_contents, environment, pressure_delta)
			transfer_moles = min(transfer_moles, (release_flow_rate/air_contents.volume)*air_contents.total_moles) //flow rate limit

			var/returnval = pump_gas_passive(src, air_contents, environment, transfer_moles)
			if(returnval >= 0)
				src.update_icon()

	if(air_contents.return_pressure() < 1)
		can_label = 1
	else
		can_label = 0

	air_contents.react() //cooking up air cans - add phoron and oxygen, then heat above PHORON_MINIMUM_BURN_TEMPERATURE

/obj/machinery/portable_atmospherics/canister/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/canister/bullet_act(var/obj/projectile/Proj)
	if(!(Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		return

	if(Proj.damage)
		src.health -= round(Proj.damage / 2)
		healthcheck()
	..()

/obj/machinery/portable_atmospherics/canister/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(!W.is_wrench() && !istype(W, /obj/item/tank) && !istype(W, /obj/item/analyzer) && !istype(W, /obj/item/pda))
		visible_message(SPAN_WARNING("\The [user] hits \the [src] with \a [W]!"))
		src.health -= W.damage_force
		healthcheck()

	if(istype(user, /mob/living/silicon/robot) && istype(W, /obj/item/tank/jetpack))
		var/datum/gas_mixture/thejetpack = W:air_contents
		var/env_pressure = thejetpack.return_pressure()
		var/pressure_delta = min(10*ONE_ATMOSPHERE - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure
		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*thejetpack.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			thejetpack.merge(removed)
			to_chat(user, "You pulse-pressurize your jetpack from the tank.")
		return

	..()

	SSnanoui.update_uis(src) // Update all NanoUIs attached to src

/obj/machinery/portable_atmospherics/canister/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(mob/user, list/params)
	return src.ui_interact(user)

/obj/machinery/portable_atmospherics/canister/ui_state(mob/user, datum/tgui_module/module)
	return GLOB.physical_state

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canister", name)
		ui.open()

/obj/machinery/portable_atmospherics/canister/ui_static_data(mob/user)
	return list(
		"defaultReleasePressure" = round(CAN_DEFAULT_RELEASE_PRESSURE),
		"minReleasePressure" = round(can_min_release_pressure),
		"maxReleasePressure" = round(can_max_release_pressure),
		"pressureLimit" = round(pressure_limit),
		"holdingTankLeakPressure" = round(TANK_LEAK_PRESSURE),
		"holdingTankFragPressure" = round(TANK_FRAGMENT_PRESSURE)
	)

/obj/machinery/portable_atmospherics/canister/ui_data()
	. = list(
		"portConnected" = !!connected_port,
		"tankPressure" = round(air_contents.return_pressure()),
		"releasePressure" = round(release_pressure),
		"valveOpen" = !!valve_open,
		//"isPrototype" = !!prototype,
		"hasHoldingTank" = !!holding
	)
/*
	if(prototype)
		. += list(
			"restricted" = restricted,
			"timing" = timing,
			"time_left" = get_time_left(),
			"timer_set" = timer_set,
			"timer_is_not_default" = timer_set != default_timer_set,
			"timer_is_not_min" = timer_set != minimum_timer_set,
			"timer_is_not_max" = timer_set != maximum_timer_set
		)
*/
	if(holding)
		. += list(
			"holdingTank" = list(
				"name" = holding.name,
				"tankPressure" = round(holding.air_contents.return_pressure())
			)
		)

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("relabel")
			if(can_label)
				var/list/colors = list(\
					"\[N2O\]" = "redws", \
					"\[N2\]" = "red", \
					"\[O2\]" = "blue", \
					"\[Phoron\]" = "orange", \
					"\[CO2\]" = "black", \
					"\[Air\]" = "grey", \
					"\[CAUTION\]" = "yellow", \
				)
				var/label = input("Choose canister label", "Gas canister") as null|anything in colors
				if(label)
					canister_color = colors[label]
					icon_state = colors[label]
					name = "Canister: [label]"
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = initial(release_pressure)
				. = TRUE
			else if(pressure == "min")
				pressure = can_min_release_pressure
				. = TRUE
			else if(pressure == "max")
				pressure = can_max_release_pressure
				. = TRUE
			else if(pressure == "input")
				pressure = input("New release pressure ([can_min_release_pressure]-[can_max_release_pressure] kPa):", name, release_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				release_pressure = clamp(round(pressure), can_min_release_pressure, can_max_release_pressure)
				investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)
		if("valve")
			if(valve_open)
				if(holding)
					release_log += "Valve was <b>closed</b> by [usr] ([usr.ckey]), stopping the transfer into the [holding]<br>"
				else
					release_log += "Valve was <b>closed</b> by [usr] ([usr.ckey]), stopping the transfer into the <font color='red'><b>air</b></font><br>"
			else
				if(holding)
					release_log += "Valve was <b>opened</b> by [usr] ([usr.ckey]), starting the transfer into the [holding]<br>"
				else
					release_log += "Valve was <b>opened</b> by [usr] ([usr.ckey]), starting the transfer into the <font color='red'><b>air</b></font><br>"
					log_open()
			valve_open = !valve_open
			. = TRUE
		if("eject")
			if(holding)
				if(valve_open)
					valve_open = 0
					release_log += "Valve was <b>closed</b> by [usr] ([usr.ckey]), stopping the transfer into the [holding]<br>"
				if(istype(holding, /obj/item/tank))
					holding.manipulated_by = usr.real_name
				holding.loc = loc
				holding = null
			. = TRUE
	update_appearance()

/obj/machinery/portable_atmospherics/canister/phoron/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/phoron, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/oxygen/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/oxygen, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/oxygen/prechilled/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/oxygen, MolesForPressure())
	src.air_contents.temperature = 80
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/nitrous_oxide/Initialize(mapload)
	. = ..()
	air_contents.adjust_gas(/datum/gas/nitrous_oxide, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/helium/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/helium, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/carbon_monoxide/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/carbon_monoxide, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/methyl_bromide/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/methyl_bromide, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/nitrodioxide/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/nitrodioxide, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/nitricoxide/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/nitricoxide, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/methane/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/methane, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/argon/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/argon, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/krypton/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/krypton, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/neon/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/neon, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/ammonia/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/ammonia, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/xenon/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/xenon, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/chlorine/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/chlorine, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/sulfur_dioxide/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/sulfur_dioxide, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/hydrogen/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/hydrogen, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/tritium/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/hydrogen/tritium, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/deuterium/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/hydrogen/deuterium, MolesForPressure())
	src.update_icon()

//Dirty way to fill room with gas. However it is a bit easier to do than creating some floor/engine/n2o -rastaf0
/obj/machinery/portable_atmospherics/canister/nitrous_oxide/roomfiller/Initialize(mapload)
	. = ..()
	air_contents.gas[/datum/gas/nitrous_oxide] = 9*4000
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/portable_atmospherics/canister/nitrous_oxide/roomfiller/LateInitialize()
	. = ..()
	var/turf/simulated/location = src.loc
	if (istype(src.loc))
		while (!location.air)
			sleep(10)
		location.assume_air(air_contents)
		air_contents = new

/obj/machinery/portable_atmospherics/canister/nitrogen/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/nitrogen, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/carbon_dioxide, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/air/Initialize(mapload)
	. = ..()
	var/list/air_mix = StandardAirMix()
	src.air_contents.adjust_multi(/datum/gas/oxygen, air_mix[/datum/gas/oxygen], /datum/gas/nitrogen, air_mix[/datum/gas/nitrogen])
	src.update_icon()

//R-UST port
// Special types used for engine setup admin verb, they contain double amount of that of normal canister.
/obj/machinery/portable_atmospherics/canister/nitrogen/engine_setup/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/nitrogen, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/engine_setup/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/carbon_dioxide, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/phoron/engine_setup/Initialize(mapload)
	. = ..()
	src.air_contents.adjust_gas(/datum/gas/phoron, MolesForPressure())
	src.update_icon()

/obj/machinery/portable_atmospherics/canister/take_damage(var/damage)
	src.health -= damage
	healthcheck()
