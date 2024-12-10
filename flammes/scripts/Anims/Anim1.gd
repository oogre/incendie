@tool
extends CharacterBody3D

signal materialChange(int, Callable)

var _id : int;
var _color : Color;
var _anim : Callable;

@export var color : Color : 
	get:
		return _color

@export var id : int :
	set(value):
		_id = value
		materialChange.emit(_id, func(mat, col, anim):
			$FRONT.material = mat
			$BACK.material = mat
			_color = col
			_anim = anim
		)
	get:
		return _id

func _ready() -> void:
	id = _id
		
func getLighAnim() -> Dictionary:
	return _anim.call()

func _physics_process(delta: float):
	if Engine.is_editor_hint():
		return
	seqentialMove(Vector3(0, -1, 0), 600)
	move_and_slide()
	
func seqentialMove(direction:Vector3, speed:float):
	if(position.y < 15):
		position.y = 80

	velocity = (transform.basis * direction).normalized() * speed
