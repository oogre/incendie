@tool
extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 24
	for bulb in $Bulbs.get_children():
		$Bulbs.remove_child(bulb)
	#for n in 400:
		#var rawBulb = {
			#"MAC_ADDRESS" : "HELLO",
			#"x" : randf_range(-10, 10),
			#"y" : randf_range(-10, 10),
			#"z" : randf_range(-15, 15)
		#}
		#var bulb = Bulb.new(n, rawBulb)
		#$Bulbs.add_child(bulb)
		#if Engine.is_editor_hint():
			#bulb.owner = get_tree().edited_scene_root
	$server_incendie.newFlamme.connect(onNewFlamme)

func _process(_delta):
	if($Bulbs.get_children().size() <= 0):
		return
	var bulbs = []
	bulbs.resize($Bulbs.get_children().size())
	for bulb in $Bulbs.get_children():
		bulbs[bulb.id % bulbs.size()] = bulb.light
	var data = PackedByteArray(bulbs)
	$server_incendie.send(data)

func onNewFlamme(id, MAC_ADDRESS, position):
	var rawBulb = {
		"MAC_ADDRESS" : MAC_ADDRESS,
		"x" : position[0],
		"y" : position[1],
		"z" : position[2]
	}
	var bulb = Bulb.new(id, rawBulb)
	bulb.setPositionHandler.connect($server_incendie.setBulbPosition)
	$Bulbs.add_child(bulb)
	if Engine.is_editor_hint():
		bulb.owner = get_tree().edited_scene_root
