extends CharacterBody3D

class_name Mover

const DancerMat = preload("res://Characters/Dancers/Materials/wireframe.tres")
var material 
var timeOffset : float = 0;
var startAt : float = 0;
 
func start() ->void:
	startAt = Time.get_ticks_msec()
	material = DancerMat.duplicate(true);
	material.set_shader_parameter("wireframeColor",   Color.from_hsv(randf_range(0.0, 1), randf_range(0.3, 0.6), 1, 1));
	$"Displayer/Front".set_surface_override_material(0, material)
	$"Displayer/Back".set_surface_override_material(0, material)
	
func isReadyToMove() ->bool :
	var time = Time.get_ticks_msec() - startAt;
	var isReady =  time > timeOffset
	visible = isReady
	return isReady

func setColor(value : Color):
	material.set_shader_parameter("wireframeColor", value);
