extends Light

class_name LightFire

var noise : FastNoiseLite
var alt_freq : float = 0.005
var oct : int = 4
var lac : int = 2
var gain : float = 0.5
var amplitude : float = 1.0 

func onStart(_bulb:Bulb) -> float:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	#noise.fréquence = fréquence
	#noise.fractal_octaves = octaves
	#noise.fractal_lacunarity = lacunarité
	#noise.fractal_gain = gain 
	return 1.0
	
func onAction(_bulb:Bulb) -> float:
	return lerp(0.75, 1.0, noise.get_noise_2d(_bulb.position.x + _bulb.position.y + _bulb.position.z, Time.get_ticks_msec() * 0.5))

func onStop(_bulb:Bulb) -> float:
	return _bulb.light
