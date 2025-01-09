extends Mover

class_name Stay 

func _ready() ->void:
	start()

func _physics_process(_delta) ->void:
	if ! isReadyToMove() : 
		return
