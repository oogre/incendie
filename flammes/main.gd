extends Node

const IncendieServerClass = preload("res://scripts/IncendieServer.gd")
const BulbClass = preload("res://scripts/Bulb.gd")

var bulbs = []
var incendie

func _ready():
	Engine.max_fps = 25
	incendie = IncendieServerClass.new()
	add_child(incendie)
	createBulbs()
		
func _process(_delta):
	incendie.controlBulbs(bulbs.map(func(bulb):
		return int(bulb.isSelected ) * 255
	))

func createBulbs():
	incendie.getBulbs(func(ids):
		bulbs = ids.map(func(id):
			var bulb = BulbClass.new(id)
			$Bulbs.add_child(bulb)
			return bulb
		)
	)
