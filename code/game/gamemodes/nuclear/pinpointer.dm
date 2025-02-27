/obj/item/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	slot_flags = SLOT_BELT
	w_class = ITEMSIZE_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_STEEL = 500)
	preserve_item = 1
	var/obj/item/disk/nuclear/the_disk = null
	var/active = 0


/obj/item/pinpointer/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!active)
		active = 1
		workdisk()
		to_chat(usr, "<span class='notice'>You activate the pinpointer</span>")
	else
		active = 0
		icon_state = "pinoff"
		to_chat(usr, "<span>You deactivate the pinpointer</span>")

/obj/item/pinpointer/proc/workdisk()
	if(!active)
		return
	if(!the_disk)
		the_disk = locate()
		if(!the_disk)
			icon_state = "pinonnull"
			return
	setDir(get_dir(src,the_disk))
	switch(get_dist(src,the_disk))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"
	spawn(5) .()

/obj/item/pinpointer/examine(mob/user, dist)
	. = ..()
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
		if(bomb.timing)
			. += "<span class = 'danger'>Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]</span>"

/obj/item/pinpointer/Destroy()
	active = 0
	..()

/obj/item/pinpointer/advpinpointer
	name = "Advanced Pinpointer"
	icon = 'icons/obj/device.dmi'
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
	var/mode = 0  // Mode 0 locates disk, mode 1 locates coordinates.
	var/turf/location = null
	var/obj/target = null

/obj/item/pinpointer/advpinpointer/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!active)
		active = 1
		if(mode == 0)
			workdisk()
		if(mode == 1)
			worklocation()
		if(mode == 2)
			workobj()
		to_chat(usr, "<span class='notice'>You activate the pinpointer</span>")
	else
		active = 0
		icon_state = "pinoff"
		to_chat(usr, "<span class='notice'>You deactivate the pinpointer</span>")

/obj/item/pinpointer/advpinpointer/proc/worklocation()
	if(!active)
		return
	if(!location)
		icon_state = "pinonnull"
		return
	setDir(get_dir(src,location))
	switch(get_dist(src,location))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"
	spawn(5) .()

/obj/item/pinpointer/advpinpointer/proc/workobj()
	if(!active)
		return
	if(!target)
		icon_state = "pinonnull"
		return
	setDir(get_dir(src,target))
	switch(get_dist(src,target))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"
	spawn(5) .()

/obj/item/pinpointer/advpinpointer/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in view(1)

	active = 0
	icon_state = "pinoff"
	target=null
	location = null

	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Location", "Disk Recovery", "Other Signature"))
		if("Location")
			mode = 1

			var/locationx = input(usr, "Please input the x coordinate to search for.", "Location?" , "") as num
			if(!locationx || !(usr in view(1,src)))
				return
			var/locationy = input(usr, "Please input the y coordinate to search for.", "Location?" , "") as num
			if(!locationy || !(usr in view(1,src)))
				return

			var/turf/Z = get_turf(src)

			location = locate(locationx,locationy,Z.z)

			to_chat(usr, "You set the pinpointer to locate [locationx],[locationy]")


			return attack_self()

		if("Disk Recovery")
			mode = 0
			return attack_self()

		if("Other Signature")
			mode = 2
			switch(alert("Search for item signature or DNA fragment?" , "Signature Mode Select" , "" , "Item" , "DNA"))
				if("Item")
					var/datum/objective/steal/itemlist
					itemlist = itemlist // To supress a 'variable defined but not used' error.
					var/targetitem = input("Select item to search for.", "Item Mode Select","") as null|anything in itemlist.possible_items
					if(!targetitem)
						return
					target=locate(itemlist.possible_items[targetitem])
					if(!target)
						to_chat(usr, "Failed to locate [targetitem]!")
						return
					to_chat(usr, "You set the pinpointer to locate [targetitem]")
				if("DNA")
					var/DNAstring = input("Input DNA string to search for." , "Please Enter String." , "")
					if(!DNAstring)
						return
					for(var/mob/living/carbon/M in GLOB.mob_list)
						if(!M.dna)
							continue
						if(M.dna.unique_enzymes == DNAstring)
							target = M
							break

			return attack_self()


///////////////////////
//nuke op pinpointers//
///////////////////////


/obj/item/pinpointer/nukeop
	var/mode = 0	//Mode 0 locates disk, mode 1 locates the shuttle
	var/obj/machinery/computer/shuttle_control/multi/syndicate/home = null

/obj/item/pinpointer/nukeop/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!active)
		active = 1
		if(!mode)
			workdisk()
			to_chat(user, "<span class='notice'>Authentication Disk Locator active.</span>")
		else
			worklocation()
			to_chat(user, "<span class='notice'>Shuttle Locator active.</span>")
	else
		active = 0
		icon_state = "pinoff"
		to_chat(user, "<span class='notice'>You deactivate the pinpointer.</span>")


/obj/item/pinpointer/nukeop/workdisk()
	if(!active) return
	if(mode)		//Check in case the mode changes while operating
		worklocation()
		return
	if(bomb_set)	//If the bomb is set, lead to the shuttle
		mode = 1	//Ensures worklocation() continues to work
		worklocation()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator active.")			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	if(!the_disk)
		the_disk = locate()
		if(!the_disk)
			icon_state = "pinonnull"
			return
//	if(loc.z != the_disk.z)	//If you are on a different z-level from the disk
//		icon_state = "pinonnull"
//	else
	setDir(get_dir(src, the_disk))
	switch(get_dist(src, the_disk))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"

	spawn(5) .()


/obj/item/pinpointer/nukeop/proc/worklocation()
	if(!active)	return
	if(!mode)
		workdisk()
		return
	if(!bomb_set)
		mode = 0
		workdisk()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
		visible_message("<span class='notice'>Authentication Disk Locator active.</span>")
		return
	if(!home)
		home = locate()
		if(!home)
			icon_state = "pinonnull"
			return
	if(loc.z != home.z)	//If you are on a different z-level from the shuttle
		icon_state = "pinonnull"
	else
		setDir(get_dir(src, home))
		switch(get_dist(src, home))
			if(0)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"

	spawn(5) .()


// This one only points to the ship.  Useful if there is no nuking to occur today.
/obj/item/pinpointer/shuttle
	var/shuttle_comp_id = null
	var/obj/machinery/computer/shuttle_control/our_shuttle = null

/obj/item/pinpointer/shuttle/attack_self(mob/user)
	. = ..()
	if(.)
		return
	if(!active)
		active = TRUE
		find_shuttle()
		to_chat(user, "<span class='notice'>Shuttle Locator active.</span>")
	else
		active = FALSE
		icon_state = "pinoff"
		to_chat(user, "<span class='notice'>You deactivate the pinpointer.</span>")

/obj/item/pinpointer/shuttle/proc/find_shuttle()
	if(!active)
		return

	if(!our_shuttle)
		for(var/obj/machinery/computer/shuttle_control/S in GLOB.machines)
			if(S.shuttle_tag == shuttle_comp_id) // Shuttle tags are used so that it will work if the computer path changes, as it does on the southern cross map.
				our_shuttle = S
				break

		if(!our_shuttle)
			icon_state = "pinonnull"
			return

	if(loc.z != our_shuttle.z)	//If you are on a different z-level from the shuttle
		icon_state = "pinonnull"
	else
		setDir(get_dir(src, our_shuttle))
		switch(get_dist(src, our_shuttle))
			if(0)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"

	spawn(5)
		.()


/obj/item/pinpointer/shuttle/merc
	shuttle_comp_id = "Mercenary"

/obj/item/pinpointer/shuttle/heist
	shuttle_comp_id = "Skipjack"
