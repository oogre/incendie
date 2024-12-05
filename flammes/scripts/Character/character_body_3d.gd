extends CharacterBody3D

const SPEED = 140.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.2


@export var targetDuration :  float = 10.0;
@export var targetTime :  float = 0;
var target;
var selfVelocity : Vector3;
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	target = $"../Bulbs".getRandomBulb();
	selfVelocity = Vector3(randf(), randf(), randf())
	
	
var _auto:bool = false
@export var automaticMove :  bool :
	set(value):
		_auto = value
	get:
		return _auto

func _input(event):
	if !automaticMove and event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		get_child(0).rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))


func _hit_building(area):
	print("_hit_building, ", area)
func _on_area_entered(area):
	print("_on_area_entered, ", area)


func _physics_process(delta: float) -> void:
	
	
	
	targetTime += delta;
	if(targetTime >= targetDuration):
		targetTime = 0
		target = $"../Bulbs".getRandomBulb();
		
	if automaticMove :
		var path = target.position - position;
		velocity = (path + selfVelocity) * 10
		
		self.look_at(target.position)
		print(target.name, ', ', target.position)
	else :
		var input_dir:Vector3
		if Input.is_action_pressed("movement_forward"):
			input_dir.y -= 1
		if Input.is_action_pressed("movement_backward"):
			input_dir.y += 1
		if Input.is_action_pressed("movement_left"):
			input_dir.x -= 1
		if Input.is_action_pressed("movement_right"):
			input_dir.x += 1
		if Input.is_action_pressed("movement_upward"):
			input_dir.z += 1
		if Input.is_action_pressed("movement_downward"):
			input_dir.z -= 1

		var direction := (transform.basis * Vector3(input_dir.x, input_dir.z, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			velocity.y = direction.y * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
