/**
 *!	Note from Carnie:
 * 	The way datum/mind stuff works has been changed a lot.
 * 	Minds now represent IC characters rather than following a client around constantly.
 *
 *? Guidelines for using minds properly:
 * -	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
 * 	ghost.mind is however used as a reference to the ghost's corpse
 *
 * -	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
 * 	the existing mind of the old mob should be transfered to the new mob like so: mind.transfer_to(new_mob)
 *
 * -	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
 * 	By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
 * 	the player.
 *
 * -	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.
 *
 * -	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
 * 	a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.
 * 	new_mob.key = key
 *
 * 	The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
 * 	However if you want that mind to have any special properties like being a traitor etc you will have to do that
 * 	yourself.
 */

/datum/mind
	/// ckey of mind
	var/ckey
	/// Replaces mob/var/original_name
	var/name
	//  todo: /mob, not /living
	/// the mob we're currently inhabiting. the mind can be referenced by many mobs, however, only one may be 'owned' by it.
	/// this functionality is used for things like aghosting and astral projection, as even though the player is in another mob,
	/// their actual mob is what owns their mind.
	var/mob/living/current

	var/mob/living/original	//TODO: remove.not used in any meaningful way ~Carn. First I'll need to tweak the way silicon-mobs handle minds.
	var/active = FALSE

	//? Characteristics
	/// characteristics holder
	var/datum/characteristics_holder/characteristics

	//? Abilities
	/// mind-level abilities
	var/list/datum/ability/abilities

	//? Preferences
	/**
	 * original save data
	 * ! TODO: REMOVE THIS; we shouldn't keep this potentially big list all round. !
	 * todo: don't actually remove it, just only save relevant data (?)
	 */
	var/list/original_save_data
	/// original economic modifier from backgrounds
	var/original_pref_economic_modifier = 1

	var/memory
	var/list/learned_recipes

	// todo: id, not title
	var/assigned_role
	var/special_role

	var/role_alt_title

	var/datum/role/job/assigned_job

	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()

	/// Tracks if this mind has been a rev or not.
	var/has_been_rev = 0

	/// Associated faction.
	var/datum/faction/faction
	/// Changeling holder.
	var/datum/changeling/changeling

	/// Is this person a chaplain or admin role allowed to use bibles.
	var/isholy = FALSE

	var/rev_cooldown = 0
	var/tcrystals = 0

	/// The world.time since the mob has been brigged, or -1 if not at all.
	var/brigged_since = -1

	/// Put this here for easier tracking ingame.
	var/datum/money_account/initial_account

	/// Used to store what traits the player had picked out in their preferences before joining, in text form.
	var/list/traits = list()

/datum/mind/New(ckey)
	src.ckey = ckey

/datum/mind/Destroy()
	QDEL_NULL(characteristics)
	QDEL_LIST_NULL(abilities)
	return ..()

//? Characteristics

/**
 * make sure we have a characteristics holder
 */
/datum/mind/proc/characteristics_holder()
	if(!characteristics)
		characteristics = new
		characteristics.associate_with_mind(src)
	return characteristics

//? Transfer

/datum/mind/proc/disassociate()
	ASSERT(!isnull(current))

	// remove characteristics
	characteristics?.disassociate_from_mob(current)
	// remove abilities
	for(var/datum/ability/ability as anything in abilities)
		ability.disassociate(current)
	// null mind
	current.mind = null

	// done
	current = null

/datum/mind/proc/associate(mob/new_character)
	ASSERT(isnull(current))
	ASSERT(isnull(new_character.mind))

	// start
	current = new_character

	// set mind
	new_character.mind = src
	// add characteristics
	characteristics?.associate_with_mob(new_character)
	// add abilities
	for(var/datum/ability/ability as anything in abilities)
		ability.associate(new_character)

	//* transfer player if necessary
	if(active)
		new_character.ckey = ckey //now transfer the ckey to link the client to our new body

/datum/mind/proc/transfer(mob/new_character)
	if(isnull(current))
		associate(new_character)
		return

	var/mob/old_character = current

	disassociate()

	if(!isnull(new_character.mind))
		new_character.mind.disassociate()

	SStgui.on_transfer(old_character, new_character)
	SSnanoui.user_transferred(old_character, new_character)

	associate(new_character)

/datum/mind/proc/store_memory(new_text)
	if((length(memory) + length(new_text)) <= MAX_MESSAGE_LEN)
		memory += "[new_text]<BR>"

/datum/mind/proc/show_memory(mob/recipient)
	var/output = "<B>[current.real_name]'s Memory</B><HR>"
	output += memory

	if(objectives.len>0)
		output += "<HR><B>Objectives:</B>"

		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

	recipient << browse(output,"window=memory")

/datum/mind/proc/edit_memory()
	if(!SSticker || !SSticker.mode)
		alert("Not before round-start!", "Alert")
		return

	var/out = "<B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"
	out += "Mind currently owned by ckey: [ckey] [active?"(synced)":"(not synced)"]<br>"
	out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"
	out += "<hr>"
	out += "Factions and special roles:<br><table>"
	out += "</table><hr>"
	out += "<b>Objectives</b></br>"

	if(objectives && objectives.len)
		var/num = 1
		for(var/datum/objective/O in objectives)
			out += "<b>Objective #[num]:</b> [O.explanation_text] "
			if(O.completed)
				out += "(<font color='green'>complete</font>)"
			else
				out += "(<font color='red'>incomplete</font>)"
			out += " <a href='?src=\ref[src];obj_completed=\ref[O]'>\[toggle\]</a>"
			out += " <a href='?src=\ref[src];obj_delete=\ref[O]'>\[remove\]</a><br>"
			num++
		out += "<br><a href='?src=\ref[src];obj_announce=1'>\[announce objectives\]</a>"

	else
		out += "None."
	out += "<br><a href='?src=\ref[src];obj_add=1'>\[add\]</a><br><br>"
	usr << browse(out, "window=edit_memory[src]")

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))	return

	else if (href_list["role_edit"])
		var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in SSjob.all_job_titles()
		if (!new_role) return
		assigned_role = new_role

	else if (href_list["memory_edit"])
		var/new_memo = sanitize(input("Write new memory", "Memory", memory) as null|message)
		if (isnull(new_memo)) return
		memory = new_memo

	else if (href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if (href_list["obj_edit"])
			objective = locate(href_list["obj_edit"])
			if (!objective) return
			objective_pos = objectives.Find(objective)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"

		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "debrain", "protect", "prevent", "harm", "brig", "hijack", "escape", "survive", "steal", "download", "mercenary", "capture", "absorb", "custom")
		if (!new_obj_type) return

		var/datum/objective/new_objective = null

		switch (new_obj_type)
			if ("survive")
				new_objective = new /datum/objective/survive
				new_objective.owner = src

			if ("custom")
				var/expl = sanitize(input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null)
				if (!expl) return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if (!new_objective) return

		if (objective)
			objectives -= objective
			objectives.Insert(objective_pos, new_objective)
		else
			objectives += new_objective

	else if (href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))	return
		objectives -= objective

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))	return
		objective.completed = !objective.completed

	else if (href_list["obj_announce"])
		var/obj_count = 1
		to_chat(current, "<font color=#4F49AF>Your current objectives:</font>")
		for(var/datum/objective/objective in objectives)
			to_chat(current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++
	edit_memory()

// check whether this mind's mob has been brigged for the given duration
// have to call this periodically for the duration to work properly
/datum/mind/proc/is_brigged(duration)
	var/turf/T = current.loc
	if(!istype(T))
		brigged_since = -1
		return 0
	var/is_currently_brigged = 0
	if(istype(T.loc,/area/security/brig))
		is_currently_brigged = 1
		for(var/obj/item/card/id/card in current)
			is_currently_brigged = 0
			break // if they still have ID they're not brigged
		for(var/obj/item/pda/P in current)
			if(P.id)
				is_currently_brigged = 0
				break // if they still have ID they're not brigged

	if(!is_currently_brigged)
		brigged_since = -1
		return 0

	if(brigged_since == -1)
		brigged_since = world.time

	return (duration <= world.time - brigged_since)

/datum/mind/proc/reset()
	assigned_role =   null
	special_role =    null
	role_alt_title =  null
	assigned_job =    null
	//faction =       null //Uncommenting this causes a compile error due to 'undefined type', fucked if I know.
	initial_account = null
	objectives =      list()
	special_verbs =   list()
	has_been_rev =    0
	rev_cooldown =    0
	brigged_since =   -1

//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.ckey = ckey
	else
		mind = new /datum/mind(ckey)
		mind.original = src
		if(SSticker)
			SSticker.minds += mind
		else
			log_world("## DEBUG: mind_initialize(): No ticker ready yet! Please inform Carn")
	if(!mind.name)
		mind.name = real_name
	mind.current = src

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)
		mind.assigned_role = USELESS_JOB

//slime
/mob/living/simple_mob/slime/mind_initialize()
	. = ..()
	mind.assigned_role = "slime"

/mob/living/carbon/alien/larva/mind_initialize()
	. = ..()
	mind.special_role = "Larva"

//AI
/mob/living/silicon/ai/mind_initialize()
	. = ..()
	mind.assigned_role = "AI"

//BORG
/mob/living/silicon/robot/mind_initialize()
	. = ..()
	mind.assigned_role = "Cyborg"

//PAI
/mob/living/silicon/pai/mind_initialize()
	. = ..()
	mind.assigned_role = "pAI"
	mind.special_role = ""

//Animals
/mob/living/simple_mob/mind_initialize()
	. = ..()
	mind.assigned_role = "Simple Mob"

/mob/living/simple_mob/animal/passive/dog/corgi/mind_initialize()
	. = ..()
	mind.assigned_role = "Corgi"

/mob/living/simple_mob/construct/shade/mind_initialize()
	. = ..()
	mind.assigned_role = "Shade"
	mind.special_role = "Cultist"

/mob/living/simple_mob/construct/artificer/mind_initialize()
	. = ..()
	mind.assigned_role = "Artificer"
	mind.special_role = "Cultist"

/mob/living/simple_mob/construct/wraith/mind_initialize()
	. = ..()
	mind.assigned_role = "Wraith"
	mind.special_role = "Cultist"

/mob/living/simple_mob/construct/juggernaut/mind_initialize()
	. = ..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = "Cultist"

//? Preferences Checks

/datum/mind/proc/original_background_religion()
	RETURN_TYPE(/datum/lore/character_background/religion)
	var/id = original_save_data?[CHARACTER_DATA_RELIGION]
	if(isnull(id))
		return
	return SScharacters.resolve_religion(id)

/datum/mind/proc/original_background_citizenship()
	RETURN_TYPE(/datum/lore/character_background/citizenship)
	var/id = original_save_data?[CHARACTER_DATA_CITIZENSHIP]
	if(isnull(id))
		return
	return SScharacters.resolve_citizenship(id)

/datum/mind/proc/original_background_origin()
	RETURN_TYPE(/datum/lore/character_background/origin)
	var/id = original_save_data?[CHARACTER_DATA_ORIGIN]
	if(isnull(id))
		return
	return SScharacters.resolve_origin(id)

/datum/mind/proc/original_background_faction()
	RETURN_TYPE(/datum/lore/character_background/faction)
	var/id = original_save_data?[CHARACTER_DATA_FACTION]
	if(isnull(id))
		return
	return SScharacters.resolve_faction(id)

/datum/mind/proc/original_background_culture()
	RETURN_TYPE(/datum/lore/character_background/culture)
	var/id = original_save_data?[CHARACTER_DATA_CULTURE]
	if(isnull(id))
		return
	return SScharacters.resolve_culture(id)

/datum/mind/proc/original_background_datums()
	if(isnull(original_save_data))
		return list()
	. = list(
		original_background_citizenship(),
		original_background_faction(),
		original_background_origin(),
		original_background_religion(),
		original_background_culture(),
	)
	listclearnulls(.)

/datum/mind/proc/original_background_ids()
	if(isnull(original_save_data))
		return list()
	. = list(
		original_save_data[CHARACTER_DATA_CITIZENSHIP],
		original_save_data[CHARACTER_DATA_ORIGIN],
		original_save_data[CHARACTER_DATA_FACTION],
		original_save_data[CHARACTER_DATA_CULTURE],
		original_save_data[CHARACTER_DATA_RELIGION],
	)
	listclearnulls(.)

//? Abilities

/**
 * adds an ability to us
 *
 * @params
 * * ability - a datum or path. once passed in, this datum is owned by the mind, and the mind can delete it at any time! if a path is passed in, this will runtime on duplicates - paths must always be unique if used in this way.
 *
 * @return TRUE / FALSE success or failure
 */
/datum/mind/proc/add_ability(datum/ability/ability)
	if(ispath(ability))
		. = FALSE
		ASSERT(!(locate(ability) in abilities))
		ability = new ability
	abilities += ability
	if(current)
		ability.associate(current)
	return TRUE

/**
 * removes, and deletes, an ability on us
 *
 * @params
 * * ability - a datum or path. paths should only be used if it's an unique ability nothing else should grant!
 *
 * @return TRUE / FALSE success or failure
 */
/datum/mind/proc/remove_ability(datum/ability/ability)
	if(ispath(ability))
		ability = locate(ability) in abilities
	if(isnull(ability))
		return FALSE
	abilities -= ability
	if(current)
		ability.disassociate(current)
	qdel(ability)
	return TRUE
