@tool
extends Node

signal bulbChange

var _incendie : IncendieServer
var incendie : IncendieServer : 
	get:
		if(!_incendie):
			_incendie = IncendieServer.new()
			add_child(_incendie)
			_incendie.name = "server"
			if Engine.is_editor_hint():
				_incendie.owner = get_tree().edited_scene_root
		return _incendie
		
@export_category("SERVER")
		
@export var USER :  String :
	set(value):
		GameState.USER = value
	get:
		return GameState.USER
		
@export var PWD :  String :
	set(value):
		GameState.PWD = value
	get:
		return GameState.PWD
		
@export var connection :  bool :
	set(value):
		var ids = await incendie.getBulbs()
		#print(ids)
		for rawBulb in ids:
			var MAC_ADDRESS = rawBulb.MAC_ADDRESS
			if(!$Bulbs.find_child(MAC_ADDRESS)):
				var bulb = Bulb.new($Bulbs.get_child_count(), rawBulb)
				bulb.selectChange.connect(bulbSelectHandler)
				bulb.setPositionHandler.connect(onSetPosition)
				$Bulbs.add_child(bulb)
				if Engine.is_editor_hint():
					bulb.owner = get_tree().edited_scene_root

func bulbSelectHandler():
	var id:String = bulbChange.get_name() + " on " + str(bulbChange.get_object_id())
	Tools.deferredSignal(id, 0.1, func():
		bulbChange.emit()
	)
	if(!bulbChange.is_connected(bulbChangeHandler)):
		bulbChange.connect(bulbChangeHandler)

func bulbChangeHandler():
	var values = $Bulbs.get_children().map(func(bulb):
		return int(bulb.isSelected)*255
	)
	incendie.controlBulbs(values)

func _on_child_exiting_tree(node):
	if(node == _incendie):
		_incendie = null

func onSetPosition(MAC_ADDRESS, position):
	incendie.setBulbPosition(MAC_ADDRESS, position)

func _ready():
	if Engine.is_editor_hint():
		return
	
	for bulb in $Bulbs.get_children():
		$Bulbs.remove_child(bulb)
	
	connection = true
