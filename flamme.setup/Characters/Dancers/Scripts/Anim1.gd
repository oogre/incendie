extends Node


func animation():
	var t0 = Time.get_ticks_msec();
	var getDuration = func():
		return (Time.get_ticks_msec() - t0) * 0.001;
	return {
		# SAW_TOOTH |\ |\ |\ 1.0->0 en 1 sec
		"action" : func() -> float :
			return 1 - abs(getDuration.call() * 2 - 1),
		"isAlive" : func() -> bool :
			return getDuration.call() <= 1.0
	}
