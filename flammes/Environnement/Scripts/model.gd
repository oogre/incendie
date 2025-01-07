extends Node3D

class_name Environnement

var walls : Node3D;

func _ready():
	walls = $Walls
	
func hideWall():
	walls.visible = false
	
func showWall():
	walls.visible = true

func _on_area_3d_body_entered(other: Node3D) -> void:
	if other is Camera : 
		showWall()

func _on_area_3d_body_exited(other: Node3D) -> void:
	if other is Camera : 
		hideWall()
