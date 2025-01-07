extends Node3D

@export var cohesionRadius : float = 2;
@export var spreadRadius : float = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	for j in range(0, 30):
		var boid = Boid.new()
		add_child(boid)
