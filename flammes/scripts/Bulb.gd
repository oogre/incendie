@tool
extends MeshInstance3D

signal lightChanged(light, callback)
signal translateHandler
signal setPositionHandler(macAddress, position)

var id:int
var old_position:Vector3
var MAC_ADDRESS:Array

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
			set_surface_override_material(0, mat)
		)
		
func with_data(_id, rawBulb):
	id = _id
	MAC_ADDRESS = rawBulb.MAC_ADDRESS
	name = str(_id) + " " + Tools.formatMacAddress(PackedByteArray(rawBulb.MAC_ADDRESS).hex_encode())
	position = Vector3(rawBulb.x, rawBulb.y, rawBulb.z)
	old_position = position
	translateHandler.connect(func():
		setPositionHandler.emit(MAC_ADDRESS, [position.x, position.y, position.z])
	)


var anims : Array[Dictionary]
func _ready() -> void:
	$Area3D.body_entered.connect(func(body):
		if body.has_method("getLighAnim"):
			var anim = body.getLighAnim()
			if anim :
				anims.append(anim)
	)
	light = 0

func _process(_delta):
	anims = anims.filter(func(anim):
		light = anim.action.call()
		return anim.isAlive.call()
	)
	if(old_position != position):
		old_position = position
		var signalId:String = translateHandler.get_name() + " on " + str(translateHandler.get_object_id())
		Tools.deferredSignal(signalId, 1.0, func():
			translateHandler.emit()
		)
