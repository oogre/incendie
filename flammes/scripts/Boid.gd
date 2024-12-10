class_name Boid extends CSGBox3D
#
	#la cohésion : pour former un groupe, les boids se rapprochent les uns des autres ;
	#la séparation : 2 boids ne peuvent pas se trouver au même endroit au même moment ;
	#l'alignement : pour rester groupés, les boids essayent de suivre un même chemin.

var speed : Vector3
var cohesionForce : Vector3
var spreadForce : Vector3
var alignForce : Vector3
var spreadDist:float = -1


func _init():
	#var area = Area3D.new()
	#var area_shape = CollisionShape3D.new()
	#var shape = BoxShape3D.new()
	#area_shape.shape = shape
	#area_shape.disabled = false
	#area.add_child(area_shape)
	#add_child(area)
	
	#use_collision = true
	#collision_layer = 1
	position = Vector3( randf_range(-2, 2),  randf_range(-2, 2),  randf_range(-2, 2))
	speed = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized() * 3
	
func _physics_process(_delta):
	speed = speed + (cohesionForce + spreadForce + alignForce) * 0.05
	position = position + speed * _delta
	
	var others:Array = $"../".get_children().filter(func(child):
		return child != self
	)
	if(spreadDist < 0 ):
		spreadDist = get_node("/root/Main/Boids").spreadRadius
	
	var spreadDistSq:float = spreadDist * spreadDist
	var center_avg:float = 1.0 / (others.size()+1)
	var speed_avg:float = 1.0 / others.size()
	var forces = others.reduce(func(forces, other):
		forces[0] += other.position * center_avg
		forces[2] += other.speed * speed_avg
		var d = position.distance_squared_to(other.position)
		if(d < spreadDistSq):
			forces[1] -= (other.position - position).normalized() * (spreadDistSq/d * 0.01)
		return forces
	, [Vector3(), Vector3(), Vector3()])
	
	cohesionForce = forces[0] - position
	spreadForce = forces[1]
	alignForce = forces[2] * 0.01
	
	pass
