extends Light

class_name LightRandom

func onStart(_bulb:Bulb):
	return 0.0
	
func onAction(_bulb:Bulb):
	return randf_range(0, 1)

func onStop(_bulb:Bulb):
	return 0.0
