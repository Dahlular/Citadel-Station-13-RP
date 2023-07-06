/datum/game_mode/var/next_spawn = 0
/datum/game_mode/var/min_autotraitor_delay = 4200  // Approx 7 minutes.
/datum/game_mode/var/max_autotraitor_delay = 12000 // Approx 20 minutes.
/datum/game_mode/var/process_count = 0

/datum/game_mode/proc/get_usable_templates(var/list/supplied_templates)
	var/list/usable_templates = list()
	return usable_templates

///process(delta_time)
///Called by the gameSSticker
/datum/game_mode/process(delta_time)
	// Slow this down a bit
	process_count++
	if(process_count >= 10)
		process_count = 0
		try_latespawn()

/datum/game_mode/proc/latespawn(var/mob/living/carbon/human/character)
	if(!character.mind)
		return
	try_latespawn(character.mind)
	return 0

/datum/game_mode/proc/try_latespawn(var/datum/mind/player, var/latejoin_only)

	if(SSemergencyshuttle.departed)
		return

	if(SSemergencyshuttle.shuttle && (SSemergencyshuttle.shuttle.moving_status == SHUTTLE_WARMUP || SSemergencyshuttle.shuttle.moving_status == SHUTTLE_INTRANSIT))
		return // Don't do anything if the shuttle's coming.

	var/mills = round_duration_in_ds
	var/mins = round((mills % 36000) / 600)
	var/hours = round(mills / 36000)

	if(hours >= 2 && mins >= 40) // Don't do anything in the last twenty minutes of the round, as well.
		return

	if(world.time < next_spawn)
		return

	message_admins("[uppertext(name)]: Attempting spawn.")


	message_admins("[uppertext(name)]: Failed to proc a viable spawn template.")
	next_spawn = world.time + rand(min_autotraitor_delay, max_autotraitor_delay)
