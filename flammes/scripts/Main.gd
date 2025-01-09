extends Node

var server : Server;
var bulbs : Bulbs;
var _connection : bool = false
var osc : OSC
signal oscOk(osc:OSC)

@export var connection :  bool :
	set(value):
		if Engine.is_editor_hint():
			_connection = value
			if value :
				server.newFlamme.connect(createFlamme)
				server.connectServer()
			else : 
				server.newFlamme.disconnect(createFlamme)
				server.disconnectServer()
				bulbs.clear()
	get : 
		return _connection
		
 #Called when the node enters the scene tree for the first time.
func _ready() -> void:
	server = $server_incendie
	bulbs = $Bulbs
	#$Bulbs.clear()
	server.newFlamme.connect(createFlamme)
	server.connectServer()
	connection = true
	#Engine.max_fps = 24
	osc = OSC.new(10000, 9999, "127.0.0.1")
	add_child(osc)
	oscOk.emit(osc)
	
func _exit_tree():
	osc.stop()
	remove_child(osc)
	
func _process(_delta):
	if bulbs.get_children().size() <= 0 :
		return
	server.send($Bulbs.getLights())

func createFlamme(id, MAC_ADDRESS, position):
	if ! bulbs : 
		return null
	var bulb = bulbs.createFlamme(id, MAC_ADDRESS, position)
	return bulb
