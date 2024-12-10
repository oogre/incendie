@tool
extends Area3D

signal materialChange(id:int, callback:Callable)

var _id : int;
var _color : Color;

@export var color : Color : 
	get:
		return _color

@export var id : int :
	set(value):
		_id = value
		materialChange.emit(_id, func(mat, col):
			$FRONT.material = mat
			$BACK.material = mat
			_color = col
		)
	get:
		return _id
