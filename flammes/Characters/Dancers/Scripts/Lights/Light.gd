extends Node

class_name Light

var duration : float
var toSpeed : float
var t0 : float

func _init(duration = 1.0):
	self.duration = duration
	self.toSpeed = 1.0/duration
	self.t0 = Time.get_ticks_msec()

func getDuration():
	return (Time.get_ticks_msec() - self.t0) * 0.001;

func getCursor():
	return getDuration() * self.toSpeed;

func isAlive(_bulb:Bulb): 
	return getDuration() <= self.duration
