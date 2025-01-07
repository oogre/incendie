extends Light

class_name LightSawtooth

func onStart(_bulb:Bulb) -> float:
	return 0.0
	
func onAction(_bulb:Bulb) -> float:
	return self.getCursor()

func onStop(_bulb:Bulb) -> float:
	return 0.0
