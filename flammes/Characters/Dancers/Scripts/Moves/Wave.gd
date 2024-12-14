extends CharacterBody3D




func _physics_process(_delta):
	if(position.x > 5):
		position.x = -2
	velocity = (transform.basis * Vector3(1, 0, 0)).normalized() * 3
	move_and_slide()
