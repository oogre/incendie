@tool
extends Node

const Bulb = preload("res://bulb.tscn")

const bulbMat = preload("res://shaders/bulb.tres")
	
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

func getLights():
	var bulbs = []
	bulbs.resize(get_children().size())
	for bulb in get_children():
		bulbs[bulb.id - 1] = bulb.light
	return PackedByteArray(bulbs)

func getRandomBulb(): 
	return get_child(randi_range(0, get_children().size()-1));

func genMaterials():
	for n in 32:
		var clone = bulbMat.duplicate(true);
		var lum : float = n * lightResolutionToFloat * 2;
		clone.set_shader_parameter("red",   lum * 1.00);
		clone.set_shader_parameter("green", lum * 0.50);
		clone.set_shader_parameter("blue",  lum * 0.25);
		lightMaterials.append(clone);

func getMaterial(lum): # lum varying [0, 255]
	var id = max(0,min(lightMaxId, int(round(lum * byteToFloat * lightMaxId))))
	return lightMaterials[id];
	
func createFlamme(id, MAC_ADDRESS, position):
	var rawBulb = {
		"MAC_ADDRESS" : MAC_ADDRESS,
		"x" : position[0],
		"y" : position[1],
		"z" : position[2]
	}
	
	
	var bulb = Bulb.instantiate()
	add_child(bulb)
	bulb.with_data(id, rawBulb)
	bulb.lightChanged.connect(onLightChange)
	bulb.owner = get_tree().edited_scene_root
	return bulb

func onLightChange(light, callback):
	callback.call(getMaterial(light))
