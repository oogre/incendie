extends Node3D

class_name Bulbs

const BulbPrefab = preload("res://Characters/Bulbs/bulb.tscn")
const bulbMat = preload("res://Characters/Bulbs/Materials/bulb.tres")
	
var lightMaterials : Array;
var lightResolution : int = 32;
var lightMaxId : int = lightResolution-1;
var byteToFloat : float = 1.0/255;
var lightResolutionToFloat : float = 1.0/lightMaxId;

func _ready() -> void:
	genMaterials()
	for bulb in get_children():
		bulb.lightChanged.connect(onLightChange)

func clear():
	for bulb in get_children():
		bulb.free()

func getLights() -> PackedByteArray:
	var bulbs = []
	bulbs.resize(get_children().size())
	#var t : float = sin(Time.get_ticks_msec() * 0.00025 * 2 * PI) * 0.5 + 0.5;
	#print(t)
	for bulb in get_children():
		bulbs[bulb.id - 1] = int(bulb.light * 255)
		#bulbs[bulb.id - 1] = int(pow(t, 0.25) * 255)
	return PackedByteArray(bulbs)

func getRandomBulb(): 
	if get_children().size() > 0 :
		return get_child(randi_range(0, get_children().size()-1));
	return null

func genMaterials():
	for n in 32:
		var clone = bulbMat.duplicate(true);
		var lum : float = n * lightResolutionToFloat * 2;
		clone.set_shader_parameter("red",   lum * 1.00);
		clone.set_shader_parameter("green", lum * 0.50);
		clone.set_shader_parameter("blue",  lum * 0.25);
		lightMaterials.append(clone);

func getMaterial(lum): # lum varying [0, 1]
	var id = max(0,min(lightMaxId, int(round(lum * lightMaxId))))
	return lightMaterials[id];
	
func createFlamme(id, MAC_ADDRESS, pos):
	var rawBulb = {
		"MAC_ADDRESS" : MAC_ADDRESS,
		"x" : pos[0],
		"y" : pos[1],
		"z" : pos[2]
	}
	
	var bulb = BulbPrefab.instantiate()
	add_child(bulb)
	bulb.lightChanged.connect(onLightChange)
	bulb.with_data(id, rawBulb)
	return bulb

func onLightChange(light, callback):
	callback.call(getMaterial(light))
