extends Node

class_name Light

var duration : float
var toSpeed : float
var t0 : float
var hasToBeRemovedWhenExited : bool = false


func _init(duration = 1.0):
	self.duration = duration
	self.toSpeed = 1.0/duration
	self.t0 = Time.get_ticks_msec()

func getDuration() -> float:
	return (Time.get_ticks_msec() - self.t0) * 0.001;

func getCursor() -> float:
	return self.getDuration() * self.toSpeed;

func isAlive(_bulb:Bulb) -> bool:
	return self.hasToBeRemovedWhenExited or self.getDuration() <= self.duration

func onStart(_bulb:Bulb) -> float:
	return 1.0
	
func onAction(_bulb:Bulb) -> float:
	return 1.0

func onStop(_bulb:Bulb) -> float:
	return 0.0
