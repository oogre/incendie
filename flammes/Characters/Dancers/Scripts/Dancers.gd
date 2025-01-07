extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"/root/Main".connect("oscOk", func(osc:OSC):
		osc.onMessage("/incendie/dancers/speed", func(msg:OSC_MSG):
			print(float(msg.getValue(0)))
		)
	)
