#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/rdserver
	name = T_BOARD("R&D server")
	build_path = /obj/machinery/r_n_d/server/core
	board_type = new /datum/frame/frame_types/machine
	origin_tech = list(TECH_DATA = 3)
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 1,
	)

/obj/item/circuitboard/rdserver/attackby(obj/item/I, mob/user)
	if(I.is_screwdriver())
		playsound(src, I.tool_sound, 50, 1)
		user.visible_message(
			SPAN_NOTICE("\The [user] adjusts the jumper on \the [src]'s access protocol pins."),
			SPAN_NOTICE("You adjust the jumper on the access protocol pins."),
			SPAN_HEAR("You hear a clicking sound."),
		)
		if(build_path == /obj/machinery/r_n_d/server/core)
			name = T_BOARD("RD Console - Robotics")
			build_path = /obj/machinery/r_n_d/server/robotics
			to_chat(user, SPAN_NOTICE("Access protocols set to robotics."))
		else
			name = T_BOARD("RD Console")
			build_path = /obj/machinery/r_n_d/server/core
			to_chat(user, SPAN_NOTICE("Access protocols set to default."))
	return

/obj/item/circuitboard/destructive_analyzer
	name = T_BOARD("destructive analyzer")
	build_path = /obj/machinery/r_n_d/destructive_analyzer
	board_type = new /datum/frame/frame_types/machine
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/scanning_module = 1,
	)

/obj/item/circuitboard/protolathe
	name = T_BOARD("protolathe")
	build_path = /obj/machinery/r_n_d/protolathe
	board_type = new /datum/frame/frame_types/machine
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2,
	)

/obj/item/circuitboard/circuit_imprinter
	name = T_BOARD("circuit imprinter")
	build_path = /obj/machinery/r_n_d/circuit_imprinter
	board_type = new /datum/frame/frame_types/machine
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2)
	req_components = list(
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 1,
	)

/obj/item/circuitboard/mechfab
	name = "Circuit board (Exosuit Fabricator)"
	build_path = /obj/machinery/mecha_part_fabricator
	board_type = new /datum/frame/frame_types/machine
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	req_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/prosthetics
	name = "Circuit board (Prosthetics Fabricator)"
	build_path = /obj/machinery/mecha_part_fabricator/pros
	board_type = new /datum/frame/frame_types/machine
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 3)
	req_components = list(
		/obj/item/stock_parts/console_screen = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/ntnet_relay
	name = "Circuit board (NTNet Quantum Relay)"
	build_path = "/obj/machinery/ntnet_relay"
	board_type = new /datum/frame/frame_types/machine
	origin_tech = list(TECH_DATA = 4)
	req_components = list(
		/obj/item/stack/cable_coil = 15,
	)

/obj/item/circuitboard/dnarevive
	name = T_BOARD("fossil reviver pod")
	build_path = /obj/machinery/fossilrevive
	board_type = new /datum/frame/frame_types/machine
	origin_tech = list(TECH_DATA = 3, TECH_BIO = 3)
	req_components = list()
