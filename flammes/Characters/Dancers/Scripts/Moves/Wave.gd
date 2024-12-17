extends Mover

class_name Wave 

func _ready() ->void:
	start()

func _physics_process(_delta) ->void:
	if ! isReadyToMove() : 
		return
	
	if(position.x > 5):
		position.x = -2
	var speed  = (transform.basis * Vector3(1, 0, 0)).normalized() * 3

	position = position + speed * _delta
