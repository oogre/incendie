@tool
extends Node

var server : CustomServer;
var bulbHolder : Bulbs;
var _connection : bool = false
@export var connection :  bool :
	set(value):
		if Engine.is_editor_hint() and server and bulbHolder:
			_connection = value
			if value :
				bulbHolder.clear()
				server.connectServer()
			else :
				server.disconnectServer()
	get : 
		return _connection

func _ready() -> void:
	server = $Server
	bulbHolder = $Bulbs
	connection = false
	bulbHolder.clear()

func _process(_delta):
	if bulbHolder.get_children().size() <= 0 :
		return
	server.send(bulbHolder.getLights())

func _on_server_new_flamme(id: int, macAddress: Array, position: Array):
	if bulbHolder :
		var bulb = bulbHolder.createFlamme(id, macAddress, position)
		bulb.setPositionHandler.connect(server.setBulbPosition)
	
