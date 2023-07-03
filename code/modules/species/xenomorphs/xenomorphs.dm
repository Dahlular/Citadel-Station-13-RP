/proc/create_new_xenomorph(alien_caste, target)

	target = get_turf(target)
	if(!target || !alien_caste) return

	var/mob/living/carbon/human/new_alien = new(target)
	new_alien.set_species("Xenomorph [alien_caste]")
	return new_alien

/mob/living/carbon/human/xdrone
	species = /datum/species/xenos/drone
	h_style = "Bald"
	faction = "xeno"

/mob/living/carbon/human/xsentinel
	species = /datum/species/xenos/sentinel
	h_style = "Bald"
	faction = "xeno"

/mob/living/carbon/human/xhunter
	species = /datum/species/xenos/hunter
	h_style = "Bald"
	faction = "xeno"

/mob/living/carbon/human/xqueen
	species = /datum/species/xenos/queen
	h_style = "Bald"
	faction = "xeno"

