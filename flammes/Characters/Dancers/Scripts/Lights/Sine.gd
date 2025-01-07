extends Light

class_name LightSine

func onStart(_bulb:Bulb) -> float:
	return 0.0
	
func onAction(_bulb:Bulb) -> float:
	return 1 - (cos(self.getCursor() * PI * 2) * 0.5 + 0.5)

func onStop(_bulb:Bulb) -> float:
	return 0.0
