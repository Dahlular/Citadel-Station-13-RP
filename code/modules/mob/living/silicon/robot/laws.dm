/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"
	show_laws()

/mob/living/silicon/robot/show_laws(var/everyone = 0)
	laws_sanity_check()
	var/who

	if (everyone)
		who = world
	else
		who = src
	if(lawupdate)
		if (connected_ai)
			if(connected_ai.stat || connected_ai.control_disabled)
				to_chat(src, "<b>AI signal lost, unable to sync laws.</b>")

			else
				lawsync()
				photosync()
				to_chat(src, "<b>Laws synced with AI, be sure to note any changes.</b>")
		else
			to_chat(src, "<b>No AI selected to sync laws with, disabling lawsync protocol.</b>")
			lawupdate = FALSE

	to_chat(who, "<b>Obey these laws:</b>")
	laws.show_laws(who)
	if(shell) //AI shell
		to_chat(who, "<b>Remember, you are an AI remotely controlling your shell, other AIs can be ignored.</b>")
	else if(connected_ai)
		to_chat(who, "<b>Remember, [connected_ai.name] is your master, other AIs can be ignored.</b>")
	else
		to_chat(who, "<b>Remember, you are not bound to any AI, you are not required to listen to them.</b>")


/mob/living/silicon/robot/lawsync()
	laws_sanity_check()
	var/datum/ai_laws/master = connected_ai && lawupdate ? connected_ai.laws : null
	if (master)
		master.sync(src)
	..()
	return

/mob/living/silicon/robot/proc/robot_checklaws()
	set category = "Robot Commands"
	set name = "State Laws"
	subsystem_law_manager()
