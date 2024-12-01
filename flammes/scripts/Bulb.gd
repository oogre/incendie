class_name Bulb extends CSGBox3D

const bulbMat = preload("res://shaders/selct.tres")
var _red : float = 0;
var _green : float = 0;
var _blue : float = 0;

var n;
@export var old_position:Vector3

signal selectChange
signal translateHandler
signal setPositionHandler(macAddress, position)

var MAC_ADDRESS:Array
var id:int



var _selected:bool = false
@export var isSelected :  bool :
	set(value):
		_selected = value
		if(value):
			light = 255
		else:
			light = 0
	get:
		return _selected
		
		
var _light : int = 0;
@export_range (0, 255) var light : float :
	get:
		return _light
	set(value):
		if(isSelected):
			_light = 255
		else:
			_light = int(value)
		var l  = _light / 127.0
		_red   = l
		_green = l * 0.75
		_blue  = l * 0.25
		
func _init(_id, rawBulb):
	#n = FastNoiseLite.new()
	#n.noise_seed = _id
	material = bulbMat.duplicate(true)
	self.id = _id
	self.MAC_ADDRESS = rawBulb.MAC_ADDRESS
	self.name = str(_id) + " " + Tools.formatMacAddress(PackedByteArray(rawBulb.MAC_ADDRESS).hex_encode())
	var area = Area3D.new()
	var area_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	area_shape.shape = shape
	area_shape.disabled = false
	area.add_child(area_shape)
	add_child(area)
	
	use_collision = true
	collision_layer = 1
	size = Vector3(0.3, 0.5, 0.3)
	position = Vector3(rawBulb.x, rawBulb.y, rawBulb.z)
	old_position = position
	
	translateHandler.connect(func():
		setPositionHandler.emit(self.MAC_ADDRESS, [position.x, position.y, position.z])
	)
	isSelected = false

func _process(_delta):
	if(old_position != position):
		old_position = position
		var signalId:String = translateHandler.get_name() + " on " + str(translateHandler.get_object_id())
		Tools.deferredSignal(signalId, 1.0, func():
			translateHandler.emit()
		)
	
	material.set_shader_parameter("red",  _red);
	material.set_shader_parameter("green", _green);
	material.set_shader_parameter("blue",  _blue);
