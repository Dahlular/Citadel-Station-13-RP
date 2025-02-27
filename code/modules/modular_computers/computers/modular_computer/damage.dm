/obj/item/modular_computer/examine(mob/user, dist)
	. = ..()
	if(damage > broken_damage)
		. += SPAN_DANGER("It is heavily damaged!")
	else if(damage)
		. += "It is damaged."

/obj/item/modular_computer/proc/break_apart()
	visible_message("\The [src] breaks apart!")
	var/turf/newloc = get_turf(src)
	new /obj/item/stack/material/steel(newloc, round(steel_sheet_cost/2))
	for(var/obj/item/computer_hardware/H in get_all_components())
		uninstall_component(null, H)
		H.forceMove(newloc)
		if(prob(25))
			H.take_damage(rand(10,30))
	qdel()

/obj/item/modular_computer/take_damage(amount, component_probability, damage_casing = TRUE, randomize = TRUE)
	if(randomize)
		// 75%-125%, rand() works with integers, apparently.
		amount *= (rand(75, 125) / 100.0)
	amount = round(amount)
	if(damage_casing)
		damage += amount
		damage = clamp( damage, 0,  max_damage)

	if(component_probability)
		for(var/obj/item/computer_hardware/H in get_all_components())
			if(prob(component_probability))
				H.take_damage(round(amount / 2))

	if(damage >= max_damage)
		break_apart()

/**
 * Stronger explosions cause serious damage to internal components
 * Minor explosions are mostly mitigitated by casing.
 */
/obj/item/modular_computer/legacy_ex_act(severity)
	take_damage(rand(100,200) / severity, 30 / severity)

/// EMPs are similar to explosions, but don't cause physical damage to the casing. Instead they screw up the components
/obj/item/modular_computer/emp_act(severity)
	take_damage(rand(100,200) / severity, 50 / severity, 0)

/**
 * "Stun" weapons can cause minor damage to components (short-circuits?)
 * "Burn" damage is equally strong against internal components and exterior casing
 * "Brute" damage mostly damages the casing.
 */
/obj/item/modular_computer/bullet_act(obj/projectile/Proj)
	switch(Proj.damage_type)
		if(BRUTE)
			take_damage(Proj.damage, Proj.damage / 2)
		if(HALLOSS)
			take_damage(Proj.damage, Proj.damage / 3, 0)
		if(BURN)
			take_damage(Proj.damage, Proj.damage / 1.5)
