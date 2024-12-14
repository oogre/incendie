extends Node

var osc:OSC
# Called when the node enters the scene tree for the first time.
func _ready():
	osc = OSC.new(9999, 8888, "127.0.0.1")
	add_child(osc)	
	osc.onMessage("/bonjour", func(msg:OSC_MSG):
		print(msg.address, " ", msg.getValue(0))
	)

func _exit_tree():
	osc.stop()
	remove_child(osc)

func sendMessage():
	var msg:OSC_MSG = OSC_MSG.new("/address")
	msg.add(123).send(osc)
