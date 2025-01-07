extends Node3D

const DancerPrefab = preload("res://Characters/Dancers/body_dancer.tscn")

func _ready():
	for j in range(0, $"../".dancerCount):
		var dancer = DancerPrefab.instantiate()
		dancer.name = str("body", j)
		add_child(dancer)
		dancer.set_script($"../".getMove())
		dancer.set_physics_process(true)
