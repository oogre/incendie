@tool
extends Node3D

const animatorMat = preload("res://shaders/wireframe.tres")

var _colorMovers : Array[Color];



var Movers = {
	"all" : [
	func(transform, position:Vector3, speed:float):
		if(position.y < 15):
			position.y = 80
		return {
			"position" : position,
			"velocity" : (transform.basis * Vector3(0, -1, 0)).normalized() * speed
		},
	func(transform, position:Vector3, speed:float):
		if(position.y > 80):
			position.y = 15
		return {
			"position" : position,
			"velocity" : (transform.basis * Vector3(0, 1, 0)).normalized() * speed
		}
]};



var _colors : Array[Color];
var _animators : Array[Material];

@export var animators : Array[Color] : 
	set(value):
		_colors.clear()
		_animators.clear()
		for color in value:
			var tempMat : Material = animatorMat.duplicate(true);
			tempMat.set_shader_parameter("wireframeColor",   color);
			_animators.append(tempMat)
			_colors.append(color)
	get:
		return _colors
		
@export var movers : Array[Color] : 
	set(value):
		_colorMovers.resize(Movers.all.size())
		value.resize(Movers.all.size())
		var i = 0
		for color in value:
			print(value)
			_colorMovers[i] = color
			i += 1
	get:
		return _colorMovers

func _ready():
	print(Movers.all)
	_colorMovers.resize(Movers.all.size())
	pass

func getMaterial(id): # lum varying [0, 255]
	return _animators[id % _animators.size()];

func getColor(id): # lum varying [0, 255]
	return _colors[id % _colors.size()];
	
	
func getMoverColor(id): # lum varying [0, 255]
	return _colorMovers[id % _colorMovers.size()];

func getMover(id): # lum varying [0, 255]
	return Movers.all[id % Movers.all.size()];

func getLighAnim(id) -> Callable:
	return func():
		var anims = Animations.getAll()
		return anims[id % anims.size()]

func _on_animator_material_change(id:int, callback:Callable) -> void:
	#if(Movers.all.size()> 0 && _colorMovers.size() > 0):
	callback.call(getMaterial(id), getColor(id), getLighAnim(id))


func _on_anim_mover_change(id: int, callback:Callable) -> void:
	if(Movers.all.size()> 0 && _colorMovers.size() > 0):
		callback.call(getMover(id), getMoverColor(id))
	pass
