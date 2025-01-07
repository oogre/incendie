extends Mover

class_name Wave 

func _ready() ->void:
	start()

func _physics_process(_delta) ->void:
	if ! isReadyToMove() : 
		return
	
	if(position.y < -10):
		position.y = 5
	var speed  = (transform.basis * Vector3(0, -1, 0)).normalized() * 1

	position = position + speed * _delta
