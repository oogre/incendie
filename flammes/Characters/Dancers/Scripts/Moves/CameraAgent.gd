extends Mover

class_name CameraAgent 

var speed : float
var targetDuration :  float = 10.0;
var targetTime :  float = 0;
var targetAngle : Vector3 = Vector3(0,0,0)
var currentAngle : Vector3 = Vector3(0,0,0)
var target : Bulb;
var selfVelocity : Vector3;
var rotationHelper : Node3D;
var bulbsWrapper : Bulbs;
var lastControlInputAt : float;
var backCounter : int = 0


func _ready() ->void:
	start()
	bulbsWrapper = $"../../../Bulbs"

func getRotation() -> Vector3:
	return Vector3(rotationHelper.rotation.x, self.rotation.y, 0)

func setRotation(angle : Vector3) -> void:
	rotationHelper.rotation = Vector3(angle.x, 0, 0)
	self.rotation = Vector3(0, angle.y, 0)

func lerpAngle(a : Vector3, b : Vector3, v) -> Vector3 : 
	return Vector3( lerp_angle(a.x, b.x, v), lerp_angle(a.y, b.y, v), lerp_angle(a.z, b.z, v))


func _physics_process(_delta) ->void:
	if ! isReadyToMove() : 
		return
	targetTime += _delta;
	var move : Vector3
	if target : 
		move = target.global_position - self.global_position
	
	if !target or targetTime >= targetDuration or move.length_squared() < 0.25 :
		speed = randf_range(0, 5)
		targetTime = 0
		target =  bulbsWrapper.getRandomBulb()
		if !target : 
			return
		move = target.global_position - self.global_position
		selfVelocity = move.normalized()
	currentAngle = self.rotation
	self.look_at(target.global_position);
	targetAngle = self.rotation
	self.rotation = lerpAngle(currentAngle, targetAngle, 0.01)
	position += selfVelocity * _delta * speed
	
