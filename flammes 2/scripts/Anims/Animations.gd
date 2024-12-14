extends Node

func getAll():
	var t0 = Time.get_ticks_msec();
	var getDuration = func():
		return (Time.get_ticks_msec() - t0) * 0.001;
	return [{
		# SAW_TOOTH |\ |\ |\ 255->0 en 1 sec
		"action" : func() -> int :
			return int(lerp(255, 0, getDuration.call())),
		"isAlive" : func() -> bool :
			return getDuration.call() <= 1.0
	},{
		# SAW_TOOTH /| /| /| 255->0 en 1 sec
		"action" : func() -> int :
			return int(lerp(0, 255, getDuration.call())),
		"isAlive" : func() -> bool :
			return getDuration.call() <= 1.0
	}];
