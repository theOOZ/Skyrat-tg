/obj/machinery/light
	icon = 'modular_skyrat/modules/aesthetics/lights/icons/lighting.dmi'
	overlayicon = 'modular_skyrat/modules/aesthetics/lights/icons/lighting_overlay.dmi'
	var/maploaded = FALSE //So we don't have a lot of stress on startup.
	var/turning_on = FALSE //More stress stuff.
	var/flicker_timer = null
	var/roundstart_flicker = FALSE

/obj/machinery/light/proc/turn_on(trigger)
	if(QDELETED(src))
		return
	turning_on = FALSE
	if(!on)
		return
	var/BR = brightness
	var/PO = bulb_power
	var/CO = bulb_colour
	if(color)
		CO = color
	var/area/A = get_area(src)
	if (A?.fire)
		CO = bulb_emergency_colour
	else if (nightshift_enabled)
		BR = nightshift_brightness
		PO = nightshift_light_power
		if(!color)
			CO = nightshift_light_color
	var/matching = light && BR == light.light_range && PO == light.light_power && CO == light.light_color
	if(!matching)
		switchcount++
		if(rigged)
			if(status == LIGHT_OK && trigger)
				explode()
		else if( prob( min(60, (switchcount^2)*0.01) ) )
			if(trigger)
				burn_out()
		else
			use_power = ACTIVE_POWER_USE
			set_light(BR, PO, CO)
			playsound(src.loc, 'modular_skyrat/modules/aesthetics/lights/sound/light_on.ogg', 65, 1)

/obj/machinery/light/proc/start_flickering()
	on = FALSE
	update(FALSE, TRUE)

	flickering = TRUE

	flicker_timer = addtimer(CALLBACK(src, .proc/flicker_on), rand(5, 10))

/obj/machinery/light/proc/stop_flickering()
	flickering = FALSE

	if(flicker_timer)
		deltimer(flicker_timer)
		flicker_timer = null

/obj/machinery/light/proc/flicker_on()
	if(!flickering)
		return

	var/area/A = get_area(src)

	if(A.lightswitch && A.power_light)
		on = TRUE
		update(FALSE, TRUE)

	flicker_timer = addtimer(CALLBACK(src, .proc/flicker_off), rand(5, 10))

/obj/machinery/light/proc/flicker_off()
	if(!flickering)
		return

	var/area/A = get_area(src)

	if(A.lightswitch && A.power_light)
		on = FALSE
		update(FALSE, TRUE)

	flicker_timer = addtimer(CALLBACK(src, .proc/flicker_on), rand(5, 50))

/obj/machinery/light/Initialize(mapload = TRUE)
	. = ..()
	if(on)
		maploaded = TRUE

	if(roundstart_flicker)
		start_flickering()

/obj/item/light/tube
	icon = 'modular_skyrat/modules/aesthetics/lights/icons/lighting.dmi'
