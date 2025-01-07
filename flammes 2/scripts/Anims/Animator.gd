@tool
extends CharacterBody3D

signal materialChange(int, Callable)
signal moverChange(int, Callable)


var _color : Color;
var _colorMover : Color;
var _anim : Callable;
var _mover : Callable;

var _idAnim : int;
var _idMover : int;

@export var color : Color : 
	get:
		return _color

@export var idAnim : int :
	set(value):
		_idAnim = value
		materialChange.emit(_idAnim, func(mat, col, anim):
			$FRONT.material = mat
			$BACK.material = mat
			_color = col
			_anim = anim
		)
	get:
		return _idAnim

@export var colorMover : Color : 
	get:
		return _colorMover
		
@export var idMover : int :
	set(value):
		_idMover = value
		moverChange.emit(_idMover, func(mover, col):
			_mover = mover
			_colorMover = col
		)
	get:
		return _idMover
		
func _ready() -> void:
	idAnim = _idAnim
	idMover = _idMover
		
func getLighAnim() -> Dictionary:
	return _anim.call()

func _physics_process(delta: float):
	if Engine.is_editor_hint() || !_mover:
		return
	
	var tmp = _mover.call(transform, position, 600)
	position = tmp.position
	velocity = tmp.velocity
	move_and_slide()
	
