extends Light

class_name LightRect

func onStart(_bulb:Bulb) -> float:
	return 1.0
	
func onAction(_bulb:Bulb) -> float:
	return 1.0

func onStop(_bulb:Bulb) -> float:
	return 0.0
