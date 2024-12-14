extends Node

func animator(duration = 1.0) :
	var toSpeed = 1.0/duration
	var t0 = Time.get_ticks_msec();
	var getDuration = func():
		return (Time.get_ticks_msec() - t0) * 0.001;
	return {
		# SAW_TOOTH /\/\/\ 1.0->0 en 1 sec
		"onStart" : func(_bulb:Bulb) -> float :
			return 1.0,
		"onAction" : func(_bulb:Bulb) -> float :
			return 1 - (cos(getDuration.call() * toSpeed * PI * 2) * 0.5 + 0.5),
		"onStop" : func(_bulb:Bulb) -> float :
			return 0.0,
		"isAlive" : func(_bulb:Bulb) -> bool :
			return getDuration.call() <= duration
	}
