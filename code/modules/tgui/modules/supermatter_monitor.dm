
/datum/tgui_module_old/supermatter_monitor
	name = "Supermatter monitor"
	tgui_id = "SupermatterMonitor"
	var/list/supermatters
	var/obj/machinery/power/supermatter/active = null		// Currently selected supermatter crystal.

/datum/tgui_module_old/supermatter_monitor/Destroy()
	. = ..()
	active = null
	supermatters = null

/datum/tgui_module_old/supermatter_monitor/New()
	..()
	refresh()

// Refreshes list of active supermatter crystals
/datum/tgui_module_old/supermatter_monitor/proc/refresh()
	supermatters = list()
	var/z = get_z(ui_host())
	if(!z)
		return
	var/valid_z_levels = (LEGACY_MAP_DATUM).get_map_levels(z)
	for(var/obj/machinery/power/supermatter/S in GLOB.machines)
		// Delaminating, not within coverage, not on a tile.
		if(S.grav_pulling || S.exploded || !(S.z in valid_z_levels) || !istype(S.loc, /turf/))
			continue
		supermatters.Add(S)

	if(!(active in supermatters))
		active = null

/datum/tgui_module_old/supermatter_monitor/proc/get_status()
	. = SUPERMATTER_INACTIVE
	for(var/obj/machinery/power/supermatter/S in supermatters)
		. = max(., S.get_status())

/datum/tgui_module_old/supermatter_monitor/ui_data(mob/user)
	var/list/data = ..()

	if(istype(active))
		var/turf/T = get_turf(active)
		if(!T)
			active = null
			return
		var/datum/gas_mixture/air = T.return_air()
		if(!istype(air))
			active = null
			return

		data["active"] = 1
		data["currentcore"] = active
		data["SM_area"] = get_area(active)
		data["SM_integrity"] = active.get_integrity()
		data["SM_power"] = active.power
		data["SM_ambienttemp"] = air.temperature
		data["SM_ambientpressure"] = air.return_pressure()
		data["SM_EPR"] = active.get_epr()
		data["SM_History"] = active.history
		//data["SM_EPR"] = active.get_epr()
		if(air.total_moles)
			data["SM_gas_O2"] = round(100*air.gas[/datum/gas/oxygen]/air.total_moles,0.01)
			data["SM_gas_CO2"] = round(100*air.gas[/datum/gas/carbon_dioxide]/air.total_moles,0.01)
			data["SM_gas_N2"] = round(100*air.gas[/datum/gas/nitrogen]/air.total_moles,0.01)
			data["SM_gas_PH"] = round(100*air.gas[/datum/gas/phoron]/air.total_moles,0.01)
			data["SM_gas_N2O"] = round(100*air.gas["/datum/gas/nitrous_oxide"]/air.total_moles,0.01)
		else
			data["SM_gas_O2"] = 0
			data["SM_gas_CO2"] = 0
			data["SM_gas_N2"] = 0
			data["SM_gas_PH"] = 0
			data["SM_gas_N2O"] = 0
	else
		var/list/SMS = list()
		for(var/obj/machinery/power/supermatter/S in supermatters)
			var/area/A = get_area(S)
			if(!A)
				continue

			SMS.Add(list(list(
			"area_name" = A.name,
			"integrity" = S.get_integrity(),
			"uid" = S.uid
			)))

		data["active"] = 0
		data["supermatters"] = SMS

	return data

/datum/tgui_module_old/supermatter_monitor/ui_act(action, params)
	if(..())
		return TRUE

	switch(action)
		if("clear")
			active = null
			. = TRUE
		if("refresh")
			refresh()
			. = TRUE
		if("set")
			var/newuid = text2num(params["set"])
			for(var/obj/machinery/power/supermatter/S in supermatters)
				if(S.uid == newuid)
					active = S
			. = TRUE

/datum/tgui_module_old/supermatter_monitor/ntos
	ntos = TRUE
