/mob/living/death(gibbed)
	wipe_fullscreens()
	if(ai_holder)
		ai_holder.go_sleep()

	for(var/s in owned_soul_links)
		var/datum/soul_link/S = s
		S.owner_died(gibbed)
	for(var/s in shared_soul_links)
		var/datum/soul_link/S = s
		S.sharer_died(gibbed)

	. = ..()
