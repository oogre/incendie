extends Light

class_name LightReverseSawtooth

func onStart(_bulb:Bulb):
	return 0.0
	
func onAction(_bulb:Bulb):
	return 1-getCursor()

func onStop(_bulb:Bulb):
	return 0.0
