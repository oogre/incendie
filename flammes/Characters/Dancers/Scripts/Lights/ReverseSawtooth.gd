extends Light

class_name LightReverseSawtooth

func onStart(_bulb:Bulb) -> float:
	return 0.0
	
func onAction(_bulb:Bulb) -> float:
	return 1-self.getCursor()

func onStop(_bulb:Bulb) -> float:
	return 0.0
