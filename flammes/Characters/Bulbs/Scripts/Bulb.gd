extends MeshInstance3D

class_name Bulb

signal lightChanged(light, callback)

var anims : Array[Dictionary]
var id : int;
var _selected:bool = false
@export var isSelected :  bool :
	set(value):
		_selected = value
		if(value):
			light = 1
		else:
			light = 0
	get:
		return _selected
		
var _light : float = 0;
@export_range (0.0, 1.0) var light : float :
	get:
		return _light
	set(value):
		if(isSelected):
			_light = 1.0
		else:
			_light = value
		updateMaterial()
		
func with_data(_id, rawBulb):
	id = _id;
	name = str(_id) + " " + Tools.formatMacAddress(PackedByteArray(rawBulb.MAC_ADDRESS).hex_encode())
	mesh = BoxMesh.new()
	position = Vector3(rawBulb.x, rawBulb.y, rawBulb.z)
	updateMaterial()

func updateMaterial():
	lightChanged.emit(light, func(mat):
		set_surface_override_material(0, mat)
	)

func _process(_delta):
	anims = anims.filter(func(anim):
		light = anim.onAction.call(self)
		if ! anim.isAlive.call(self) : 
			light = anim.onStop.call(self)
			return false
		return true
	)

func _on_entered(other: Area3D) -> void:
	var dancer = other.get_parent().get_parent();
	if dancer is Dancer : 
		var anim = dancer.getLighAnim()
		light = anim.onStart.call(self)
		anims.append(anim);
		

func _on_exited(other: Area3D) -> void:
	var dancer = other.get_parent().get_parent();
	if dancer is Dancer : 
		pass
	pass
