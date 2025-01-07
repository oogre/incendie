extends Node3D


func get_rand_pos():
	return randf_range(-2, 2)

var direction = Vector3(0, 0, 0)
var velocity = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector3(get_rand_pos(), get_rand_pos(), get_rand_pos())
	direction = Vector3(get_rand_pos(), get_rand_pos(), get_rand_pos()).normalized() * PI
	#velocity = 0.1
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#position += direction * velocity
	#print(position)
	pass
