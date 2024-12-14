extends Node

var all : Array[Callable] = [
	func(transform, position:Vector3, speed:float):
		if(position.y < 15):
			position.y = 80
		return {
			"position" : position,
			"velocity" : (transform.basis * Vector3(0, -1, 0)).normalized() * speed
		},
	func(transform, position:Vector3, speed:float):
		if(position.y > 80):
			position.y = 15
		return {
			"position" : position,
			"velocity" : (transform.basis * Vector3(0, 1, 0)).normalized() * speed
		}
];
