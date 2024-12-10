@tool
extends Node3D

const animatorMat = preload("res://shaders/wireframe.tres")

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

func getMaterial(id): # lum varying [0, 255]
	return _animators[id % _animators.size()];

func getColor(id): # lum varying [0, 255]
	return _colors[id % _colors.size()];

func getLighAnim(id) -> Callable:
	return func():
		var t0 = Time.get_ticks_msec();
		var getDuration = func():
			return (Time.get_ticks_msec() - t0) * 0.001;
		var anims = [{
			# SAW_TOOTH |\ |\ |\ 255->0 en 1 sec
			"action" : func() -> int :
				return int(lerp(255, 0, getDuration.call())),
			"isAlive" : func() -> bool :
				return getDuration.call() <= 1.0
		},{
			# SAW_TOOTH /| /| /| 255->0 en 1 sec
			"action" : func() -> int :
				return int(lerp(0, 255, getDuration.call())),
			"isAlive" : func() -> bool :
				return getDuration.call() <= 1.0
		}]
		return anims[id % anims.size()]

func _on_animator_material_change(id:int, callback:Callable) -> void:
	callback.call(getMaterial(id), getColor(id), getLighAnim(id))
