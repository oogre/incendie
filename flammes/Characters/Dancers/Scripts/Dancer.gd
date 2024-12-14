extends Node

class_name Dancer

const DancerPrefab = preload("res://Characters/Dancers/body_dancer.tscn")

const LightsScripts : Array[Resource] = [
	preload("res://Characters/Dancers/Scripts/Lights/Sawtooth.gd"),
	preload("res://Characters/Dancers/Scripts/Lights/ReverseSawtooth.gd"),
	preload("res://Characters/Dancers/Scripts/Lights/Sine.gd"),
]
enum LIGHTS_TYPES { Sawtooth, ReverseSawtooth, Sine }

const MovesScripts : Array[Resource] = [
	preload("res://Characters/Dancers/Scripts/Moves/Boid.gd"),
	preload("res://Characters/Dancers/Scripts/Moves/Wave.gd")
]
enum MOVE_TYPES { BOID , WAVE }

@export_category("Light Animation")
var _lightType : int
@export var lightType: LIGHTS_TYPES : 
	set(value):
		_lightType = value
	get : 
		return LIGHTS_TYPES[LIGHTS_TYPES.find_key(_lightType)]
@export_range(0.0, 10.0) var duration : float = 1.0;


@export_category("Dancer Moves")
var _moveType : int
@export var moveType: MOVE_TYPES : 
	set(value):
		_moveType = value
	get : 
		return MOVE_TYPES[MOVE_TYPES.find_key(_moveType)]
@export_range(0, 100) var dancerCount : int = 1


func getLighAnim():
	return LightsScripts[lightType].new().animator(duration)

func getMove():
	return MovesScripts[moveType]

func _ready():
	for j in range(0, dancerCount):
		var dancer = DancerPrefab.instantiate()
		dancer.name = str("body", j)
		add_child(dancer)
		dancer.set_script(getMove())
		dancer.set_physics_process(true)
