extends Light

class_name LightRandom

func onStart(_bulb:Bulb) -> float:
	return 0.0
	
func onAction(_bulb:Bulb) -> float:
	return randf_range(0, 1)

func onStop(_bulb:Bulb) -> float:
	return 0.0
