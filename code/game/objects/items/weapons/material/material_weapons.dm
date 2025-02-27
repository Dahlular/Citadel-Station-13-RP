// SEE code/modules/materials/materials.dm FOR DETAILS ON INHERITED DATUM.
// This class of weapons takes force and appearance data from a material datum.
// They are also fragile based on material data and many can break/smash apart.
/obj/item/material
	health = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	icon = 'icons/obj/weapons.dmi'
	gender = NEUTER
	throw_speed = 3
	throw_range = 7
	w_class = ITEMSIZE_NORMAL
	sharp = 0
	edge = 0
	item_icons = list(
			SLOT_ID_LEFT_HAND = 'icons/mob/items/lefthand_material.dmi',
			SLOT_ID_RIGHT_HAND = 'icons/mob/items/righthand_material.dmi',
			)

	var/applies_material_colour = 1
	var/unbreakable = 0		//Doesn't lose health
	var/fragile = 0			//Shatters when it dies
	var/dulled = 0			//Has gone dull
	var/can_dull = 1		//Can it go dull?
	var/force_divisor = 0.3
	var/thrown_force_divisor = 0.3
	var/dulled_divisor = 0.1	//Just drops the damage to a tenth
	var/default_material = MAT_STEEL
	var/datum/material/material
	var/drops_debris = 1
	// todo: proper material opt-out system on /atom level or something, this is trash
	var/no_force_calculations = FALSE

/obj/item/material/Initialize(mapload, material_key)
	. = ..()
	if(!material_key)
		material_key = default_material
	set_material(material_key)
	if(!material)
		qdel(src)
		return

	materials = material.get_matter()
	if(materials.len)
		for(var/material_type in materials)
			if(!isnull(materials[material_type]))
				materials[material_type] *= force_divisor // May require a new var instead.

	if(!(material.conductive))
		src.atom_flags |= NOCONDUCT

/obj/item/material/get_material()
	return material

/obj/item/material/set_material_parts(list/parts)
	. = ..()
	// todo: this is shit but whatever, we'll redo this later.
	if(length(parts) >= 1)
		set_material(parts[parts[1]])

/obj/item/material/proc/update_force()
	if(no_force_calculations)
		return
	if(edge || sharp)
		damage_force = material.get_edge_damage()
	else
		damage_force = material.get_blunt_damage()
	damage_force = round(damage_force*force_divisor)
	if(dulled)
		damage_force = round(damage_force*dulled_divisor)
	throw_force = round(material.get_blunt_damage()*thrown_force_divisor)
	// todo: remove, shitcode
	if(material.name == "supermatter")
		damtype = BURN //its hot
		damage_force = 150 //double the force of a durasteel claymore.
		armor_penetration = 100 //regardless of armor
		throw_force = 150

	//spawn(1)
	//	to_chat(world, "[src] has damage_force [damage_force] and throw_force [throw_force] when made from default material [material.name]")

/obj/item/material/proc/set_material(datum/material/new_material)
	if(istype(new_material))
		material = new_material
	else
		material = get_material_by_name(new_material) || SSmaterials.get_material(new_material)
	if(!material)
		qdel(src)
	else
		name = "[material.display_name] [initial(name)]"
		health = round(material.integrity/10)
		if(applies_material_colour)
			color = material.icon_colour
		if(material.products_need_process())
			START_PROCESSING(SSobj, src)
		update_force()

/obj/item/material/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/material/melee_mob_hit(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	. = ..()
	if(!unbreakable)
		if(material.is_brittle())
			health = 0
		else if(!prob(material.hardness))
			health--
		check_health()

/obj/item/material/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/whetstone))
		var/obj/item/whetstone/whet = W
		repair(whet.repair_amount, whet.repair_time, user)
	if(istype(W, /obj/item/material/sharpeningkit))
		var/obj/item/material/sharpeningkit/SK = W
		repair(SK.repair_amount, SK.repair_time, user)
	..()

/obj/item/material/proc/check_health(var/consumed)
	if(health<=0)
		if(fragile)
			shatter(consumed)
		else if(!dulled && can_dull)
			dull()

/obj/item/material/proc/shatter(var/consumed)
	var/turf/T = get_turf(src)
	visible_message("<span class='danger'>\The [src] [material.destruction_desc]!</span>")
	playsound(src, "shatter", 70, 1)
	if(!consumed && drops_debris)
		material.place_shard(T)
	qdel(src)

/obj/item/material/proc/dull()
	var/turf/T = get_turf(src)
	T.visible_message("<span class='danger'>\The [src] goes dull!</span>")
	playsound(src, "shatter", 70, 1)
	dulled = 1
	if(is_sharp() || has_edge())
		sharp = 0
		edge = 0

/obj/item/material/proc/repair(var/repair_amount, var/repair_time, mob/living/user)
	if(!fragile)
		if(health < initial(health))
			user.visible_message("[user] begins repairing \the [src].", "You begin repairing \the [src].")
			if(do_after(user, repair_time))
				user.visible_message("[user] has finished repairing \the [src]", "You finish repairing \the [src].")
				health = min(health + repair_amount, initial(health))
				dulled = 0
				sharp = initial(sharp)
				edge = initial(edge)
		else
			to_chat(user, "<span class='notice'>[src] doesn't need repairs.</span>")
	else
		to_chat(user, "<span class='warning'>You can't repair \the [src].</span>")
		return

/obj/item/material/proc/sharpen(var/material, var/sharpen_time, var/kit, mob/living/M)
	if(!fragile)
		if(health < initial(health))
			to_chat(M, "You should repair [src] first. Try using [kit] on it.")
			return FALSE
		M.visible_message("[M] begins to replace parts of [src] with [kit].", "You begin to replace parts of [src] with [kit].")
		if(do_after(usr, sharpen_time))
			M.visible_message("[M] has finished replacing parts of [src].", "You finish replacing parts of [src].")
			src.set_material(material)
			return TRUE
	else
		to_chat(M, "<span class = 'warning'>You can't sharpen and re-edge [src].</span>")
		return FALSE

/*
Commenting this out pending rebalancing of radiation based on small objects.
/obj/item/material/process(delta_time)
	if(!material.radioactivity)
		return
	for(var/mob/living/L in range(1,src))
		L.apply_effect(round(material.radioactivity/30),IRRADIATE,0)
*/

/*
// Commenting this out while fires are so spectacularly lethal, as I can't seem to get this balanced appropriately.
/obj/item/material/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	TemperatureAct(exposed_temperature)

// This might need adjustment. Will work that out later.
/obj/item/material/proc/TemperatureAct(temperature)
	health -= material.combustion_effect(get_turf(src), temperature, 0.1)
	check_health(1)

/obj/item/material/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		if(material.ignition_point && WT.remove_fuel(0, user))
			TemperatureAct(150)
	else
		return ..()
*/
