extends Light

class_name LightSine

func onStart(_bulb:Bulb):
	return 0.0
	
func onAction(_bulb:Bulb):
	return 1 - (cos(getCursor() * PI * 2) * 0.5 + 0.5)

func onStop(_bulb:Bulb):
	return 0.0
