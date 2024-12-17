extends CharacterBody3D

class_name Mover

var timeOffset : float = 0;
var startAt : float = 0;

func start() ->void:
	startAt = Time.get_ticks_msec()

func isReadyToMove() ->bool :
	var time = Time.get_ticks_msec() - startAt;
	var isReady =  time > timeOffset
	visible = isReady
	return isReady
