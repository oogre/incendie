extends Node

var timers = {}

func deferredSignal(id:String, time:float, action:Callable):
	if(!timers.has(id)):
		timers[id] = get_tree().create_timer(time)
		timers[id].timeout.connect(func():
			action.call()
			timers.erase(id)
		)
	else : 
		timers[id].time_left = time

func formatMacAddress(text:String):
	text = text.to_upper()
	var arr = [ ]
	var i = 0
	while i * 2 < text.length():
		arr.push_back( text.substr(i*2, 2) )
		i += 1
	var out = arr[0];
	for j in range(1, arr.size()):
		out += "-"+arr[j]
	return out
