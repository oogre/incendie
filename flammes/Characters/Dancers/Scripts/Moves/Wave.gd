extends Mover

class_name Wave 

func _ready() ->void:
	start()

func _physics_process(_delta) ->void:
	if ! isReadyToMove() : 
		return
	
	if(position.y < -1):
		position.y = 1
	var speed  = (transform.basis * Vector3(0, -1, 0)).normalized() * 0.1

	position = position + speed * _delta
