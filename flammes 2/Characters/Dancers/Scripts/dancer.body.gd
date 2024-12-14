extends CharacterBody3D

class_name DancerBody

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float):
	velocity = (transform.basis * Vector3(0, 0, sin(Time.get_ticks_msec() * 0.001))).normalized() * 20.0
	move_and_slide()
