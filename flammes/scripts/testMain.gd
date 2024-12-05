@tool
extends Node


var _connection : bool = false
@export var connection :  bool :
	set(value):
		if Engine.is_editor_hint():
			_connection = value
			if value :
				$server_incendie.newFlamme.connect(createFlamme)
				$server_incendie.connectServer()
			else : 
				$server_incendie.newFlamme.disconnect(createFlamme)
				$server_incendie.disconnectServer()
				$Bulbs.clear()
	get : 
		return _connection

var _simulate:bool = false
@export var simulate :  bool :
	set(value):
		if Engine.is_editor_hint():
			_simulate = value;
			if(value):
				var bulb;
				if(_simulate):
					for n in 400:
						if(n < 200):
							bulb = createFlamme(n, [0, 0, 0, 0, int(n/256.0), n % 256 ], [randf_range(-10, 10), randf_range(-10, 10), randf_range(-10, 10)])
						else : 
							bulb = createFlamme(n, [0, 0, 0, 0, int(n/256.0), n % 256 ], [randf_range(-20, 20), randf_range(-24, -10), randf_range(-20, 25)])
						var r = randf()
						bulb.light = r * r * r * 255
			else:
				$Bulbs.clear()
	get:
		return _simulate
		
 #Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		$server_incendie.newFlamme.connect(createFlamme)
	else : 
		$server_incendie.disconnectServer()
		$Bulbs.clear()
		$server_incendie.newFlamme.connect(createFlamme)
		$server_incendie.connectServer()
		
	#Engine.max_fps = 24
	pass
	
func _process(_delta):
	if $Bulbs.get_children().size() <= 0 :
		return
	if !Engine.is_editor_hint():
		$Bulbs.getRandomBulb().light = int(randf_range(0, 255))
	$server_incendie.send($Bulbs.getLights())

func createFlamme(id, MAC_ADDRESS, position):
	var bulb = $Bulbs.createFlamme(id, MAC_ADDRESS, position)
	if Engine.is_editor_hint():
		bulb.setPositionHandler.connect($server_incendie.setBulbPosition)
	return bulb
