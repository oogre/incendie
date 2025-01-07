extends Mover

class_name Grower 

func _ready() ->void:
	start()

func _physics_process(_delta) ->void:
	if ! isReadyToMove() : 
		return
	
	if(scale.x > 5):
		scale.x = 0
	
	var speed = Vector3(1, 0, 0).normalized() * 3
	scale = scale + speed * _delta
