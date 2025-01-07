extends Node

class_name Dancer

const DancerPrefab = preload("res://Characters/Dancers/body_dancer.tscn")

const LightsScripts : Array[Resource] = [
	preload("res://Characters/Dancers/Scripts/Lights/Nothing.gd"),
	preload("res://Characters/Dancers/Scripts/Lights/Sawtooth.gd"),
	preload("res://Characters/Dancers/Scripts/Lights/ReverseSawtooth.gd"),
	preload("res://Characters/Dancers/Scripts/Lights/Sine.gd"),
	preload("res://Characters/Dancers/Scripts/Lights/Rect.gd"),
	preload("res://Characters/Dancers/Scripts/Lights/Random.gd"),
]
enum LIGHTS_TYPES { Nothing, Sawtooth, ReverseSawtooth, Sine, Rect, Random }

const MovesScripts : Array[Resource] = [
	preload("res://Characters/Dancers/Scripts/Moves/Boid.gd"),
	preload("res://Characters/Dancers/Scripts/Moves/Wave.gd"),
	preload("res://Characters/Dancers/Scripts/Moves/Grower.gd"),
	preload("res://Characters/Dancers/Scripts/Moves/CameraAgent.gd")
]

enum MOVE_TYPES { BOID , WAVE, GROWER, CAMERA_AGENT }

@export_category("Light Animation")
var _lightType : int
@export var lightType: LIGHTS_TYPES : 
	set(value):
		_lightType = value
	get : 
		return LIGHTS_TYPES[LIGHTS_TYPES.find_key(_lightType)]
@export_range(0.250, 10.0, 0.250) var duration : float = 1.0;

@export var remove_on_exited : bool = false

@export_category("Dancer Moves")
var _moveType : int
@export var moveType: MOVE_TYPES : 
	set(value):
		_moveType = value
	get : 
		return MOVE_TYPES[MOVE_TYPES.find_key(_moveType)]
@export_range(0, 100) var dancerCount : int = 1
@export_range(0, 3, 0.1) var delayBetween : float = 0

func getLighAnim() -> Light:
	var lightObject : Light = LightsScripts[lightType].new(duration)
	lightObject.hasToBeRemovedWhenExited = remove_on_exited
	return lightObject

func getMove():
	return MovesScripts[moveType]

func _ready():
	for j in range(0, dancerCount):
		var dancer = DancerPrefab.instantiate()
		dancer.name = str("body", j)
		self.add_child(dancer)
		dancer.set_script(getMove())
		dancer.timeOffset = delayBetween * 1000 * j
		dancer._ready()
		dancer.set_physics_process(true)
