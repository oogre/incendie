extends CharacterBody3D

class_name Camera

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.2

@export var automaticMoveDelay :  float = 10.0;
@export var targetDuration :  float = 15.0;
@export var targetTime :  float = 0;

var targetAngle : Vector3 = Vector3(0,0,0)
var currentAngle : Vector3 = Vector3(0,0,0)
var target : Bulb;
var selfVelocity : Vector3;
var rotationHelper : Node3D;
var bulbsWrapper : Bulbs;
var lastControlInputAt : float;
var backCounter : int = 0

func isAutomatic():
	return Time.get_ticks_msec() - lastControlInputAt > (automaticMoveDelay * 1000);

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	rotationHelper = $Rotation_Helper
	bulbsWrapper = $"../Bulbs"

func _input(event):
	lastControlInputAt = Time.get_ticks_msec();
	
	if (event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		rotationHelper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		rotationHelper.rotation.x = max(min(rotationHelper.rotation.x, PI *0.3), PI * -0.3)
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

func getRotation() -> Vector3:
	return Vector3(rotationHelper.rotation.x, self.rotation.y, 0)

func setRotation(angle : Vector3) -> void:
	rotationHelper.rotation = Vector3(angle.x, 0, 0)
	self.rotation = Vector3(0, angle.y, 0)

func lerpAngle(a : Vector3, b : Vector3, v) -> Vector3 : 
	return Vector3( lerp_angle(a.x, b.x, v), lerp_angle(a.y, b.y, v), lerp_angle(a.z, b.z, v))

func _physics_process(delta: float) -> void:
	if isAutomatic() :
		targetTime += delta;
		if !target or targetTime >= targetDuration:
			targetTime = 0
			target = bulbsWrapper.getRandomBulb()
			var move = target.global_position - self.global_position
			if backCounter > 0 or move.length_squared() > 4000 :
				if backCounter <= 0 :
					backCounter = randi_range(1, 10)
				selfVelocity = move.normalized()
			else :
				selfVelocity = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * 0.5
			backCounter-=1
		currentAngle = getRotation()
		setRotation(Vector3(0,0,0))
		self.look_at(target.global_position);
		targetAngle = self.rotation
		setRotation(lerpAngle(currentAngle, targetAngle, 0.005))
		position = position + selfVelocity * delta * 2
	else :
		var input_dir:Vector3
		if Input.is_action_pressed("movement_forward"):
			lastControlInputAt = Time.get_ticks_msec();
			input_dir.y -= 1
		if Input.is_action_pressed("movement_backward"):
			lastControlInputAt = Time.get_ticks_msec();
			input_dir.y += 1
		if Input.is_action_pressed("movement_left"):
			lastControlInputAt = Time.get_ticks_msec();
			input_dir.x -= 1
		if Input.is_action_pressed("movement_right"):
			lastControlInputAt = Time.get_ticks_msec();
			input_dir.x += 1
		if Input.is_action_pressed("movement_upward"):
			lastControlInputAt = Time.get_ticks_msec();
			input_dir.z += 1
		if Input.is_action_pressed("movement_downward"):
			lastControlInputAt = Time.get_ticks_msec();
			input_dir.z -= 1
		
		var cameraRotation = Vector3(Input.get_action_strength("camera_down") - Input.get_action_strength("camera_up"), Input.get_action_strength("camera_left") - Input.get_action_strength("camera_right"), 0)
		if cameraRotation.length_squared() >= 0.2 :
			lastControlInputAt = Time.get_ticks_msec();
			rotationHelper.rotate_x(cameraRotation.x * delta)
			self.rotate_y(cameraRotation.y * delta)


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
