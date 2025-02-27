#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

/obj/item/circuitboard/papershredder
	name = T_BOARD("papershredder")
	build_path = /obj/machinery/papershredder
	board_type = new /datum/frame/frame_types/machine
	materials = list(MAT_STEEL = 50, MAT_GLASS = 50)
	req_components = list(
		/obj/item/stock_parts/gear = 2,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/motor = 1,
	)
