var/global/list/all_objectives = list()

/datum/objective
	/// Who owns the objective.
	var/datum/mind/owner = null
	/// What that person is supposed to do.
	var/explanation_text = "Nothing"
	/// If they are focused on a particular person.
	var/datum/mind/target = null
	/// If they are focused on a particular number. Steal objectives have their own counter.
	var/target_amount = 0
	/// Currently only used for custom objectives.
	var/completed = 0

/datum/objective/New(text)
	all_objectives |= src
	if(text)
		explanation_text = text
	..()

/datum/objective/Destroy()
	all_objectives -= src
	..()

/datum/objective/proc/check_completion()
	return completed

/datum/objective/survive
	explanation_text = "Stay alive until the end."

/datum/objective/survive/check_completion()
	if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
		return FALSE		//Brains no longer win survive objectives. --NEO
	if(issilicon(owner.current) && owner.current != owner.original)
		return FALSE
	return TRUE
