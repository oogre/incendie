extends Mover

class_name Boid 
#
	#la cohésion : pour former un groupe, les boids se rapprochent les uns des autres ;
	#la séparation : 2 boids ne peuvent pas se trouver au même endroit au même moment ;
	#l'alignement : pour rester groupés, les boids essayent de suivre un même chemin.

var cohesionRadius : float = 2;
var spreadRadius : float = 1;


var speed : Vector3
var cohesionForce : Vector3
var spreadForce : Vector3
var alignForce : Vector3
var spreadDist:float = -1


func _ready():
	start()
	position = Vector3( randf_range(-2, 2),  randf_range(-2, 2),  randf_range(-2, 2))
	speed = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized() * 3
	
func _physics_process(_delta):
	if ! isReadyToMove() : 
		return
		
	speed = speed + (cohesionForce + spreadForce + alignForce) * 0.05
	position = position + speed * _delta
	
	var others:Array = $"../".get_children().filter(func(child):
		return child != self
	)
	if(spreadDist < 0 ):
		spreadDist = spreadRadius
	
	var spreadDistSq:float = spreadDist * spreadDist
	var center_avg:float = 1.0 / (others.size()+1)
	var speed_avg:float = 1.0 / others.size()
	var forces = others.reduce(func(_forces, other):
		_forces[0] += other.position * center_avg
		_forces[2] += other.speed * speed_avg
		var d = position.distance_squared_to(other.position)
		if(d < spreadDistSq):
			_forces[1] -= (other.position - position).normalized() * (spreadDistSq/d * 0.01)
		return _forces
	, [Vector3(), Vector3(), Vector3()])
	
	cohesionForce = forces[0] - position
	spreadForce = forces[1]
	alignForce = forces[2] * 0.01
	
	pass
