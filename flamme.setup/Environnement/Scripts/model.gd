extends Node3D

class_name Environnement


func hideWall():
	$Walls.visible = false
	
func showWall():
	$Walls.visible = true

func _on_area_3d_body_entered(other: Node3D) -> void:
	if other is Camera : 
		showWall()


func _on_area_3d_body_exited(other: Node3D) -> void:
	if other is Camera : 
		hideWall()
