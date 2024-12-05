@tool
extends CSGBox3D
class_name Bulb

signal lightChanged(light, callback)
signal translateHandler
signal setPositionHandler(macAddress, position)

var old_position:Vector3
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
		lightChanged.emit(_light, func(mat):
			material = mat
		)
		
func with_data(_id, rawBulb):
	self.id = _id
	self.MAC_ADDRESS = rawBulb.MAC_ADDRESS
	self.name = str(_id) + " " + Tools.formatMacAddress(PackedByteArray(rawBulb.MAC_ADDRESS).hex_encode())
	self.size = Vector3(0.3, 0.5, 0.3)
	self.position = Vector3(rawBulb.x, rawBulb.y, rawBulb.z)
	self.old_position = position
	translateHandler.connect(func():
		setPositionHandler.emit(MAC_ADDRESS, [position.x, position.y, position.z])
	)
	#var area = Area3D.new()
	#var area_shape = CollisionShape3D.new()
	#var shape = BoxShape3D.new()
	#area_shape.shape = shape
	#area_shape.disabled = false
	#area.add_child(area_shape)
	#add_child(area)
	
	return self

func _process(_delta):
	
	if(self.old_position != self.position):
		
		self.old_position = self.position
		var signalId:String = translateHandler.get_name() + " on " + str(translateHandler.get_object_id())
		Tools.deferredSignal(signalId, 1.0, func():
			translateHandler.emit()
		)
