class_name Bulb extends CSGBox3D

static var COUNTER = 0

static var selectedBulbMat = preload("res://shaders/selct.tres")
static var unselectedBulbMat = preload("res://shaders/unselct.tres")

var ID = 0
var MAC_ADDRESS
var isSelected = false

func get_rand_pos():
	return randf_range(-2, 2)

func select():
	isSelected = true
	material = selectedBulbMat
	return self
	
func unselect():
	isSelected = false
	material = unselectedBulbMat
	pass
	
func _init(MAC_ADDRESS):
	self.MAC_ADDRESS = MAC_ADDRESS
	self.ID = Bulb.COUNTER
	
	var area = Area3D.new()
	var area_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	
	area_shape.shape = shape
	area_shape.disabled = false
	area.add_child(area_shape)
	add_child(area)
	
	use_collision = true
	collision_layer = 1
	position = Vector3(get_rand_pos(), get_rand_pos(), get_rand_pos())
	rotation = Vector3(get_rand_pos(), get_rand_pos(), get_rand_pos()).normalized() * PI

	unselect()
	
	Bulb.COUNTER += 1
	
