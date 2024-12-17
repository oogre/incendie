extends Light

class_name LightSawtooth

func onStart(_bulb:Bulb):
	return 0.0
	
func onAction(_bulb:Bulb):
	return getCursor()

func onStop(_bulb:Bulb):
	return 0.0
