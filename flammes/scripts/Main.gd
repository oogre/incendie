extends Node

const FLAME_LENGTH = 1000

const PARTICLE_LENGTH = 1

func get_rand_pos():
	return randf_range(-2, 2)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	for n in FLAME_LENGTH :
		$Bulbs.add_child($Bulbs/Box.duplicate())
				
	for n in PARTICLE_LENGTH :
		$Particles.add_child($Particles/particle.duplicate())
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
