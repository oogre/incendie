extends MeshInstance3D

class_name Bulb

signal lightChanged(light, callback)

var anims : Array[Light]

var animations : Dictionary

var id : int;
var _selected:bool = false
var _minLight : float = 0;
var _maxLight : float = 1;

@export var minLight :  float :
	set (value):
		_minLight = value
		updateMaterial()
	get :
		return _minLight

@export var maxLight :  float :
	set (value):
		_maxLight = value
		updateMaterial()
	get :
		return _maxLight

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
		return min(_maxLight, max(_minLight, _light))
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
	
	$"/root/Main".osc.onMessage("/incendie/light/minimum", func(msg:OSC_MSG):
		minLight = float(msg.getValue(0))
	)
	
	$"/root/Main".osc.onMessage("/incendie/light/maximum", func(msg:OSC_MSG):
		maxLight = float(msg.getValue(0))
	)
	
	updateMaterial()

func updateMaterial() -> void:
	lightChanged.emit(light, func(mat):
		set_surface_override_material(0, mat)
	)

func _process(_delta) -> void:
	for dancerName in animations:
		if animations[dancerName].isAlive.call(self):
			light = animations[dancerName].onAction.call(self)
		else : 
			light = animations[dancerName].onStop.call(self)
			animations.erase(dancerName)

func _on_entered(other: Area3D) -> void:
	var interactor = other.get_parent();
	var dancer = interactor.get_parent();
	if dancer is Dancer : 
		var dancerName : String = str(dancer.name, ".",interactor.name)
		if ! animations.has(dancerName) : 
			var anim = dancer.getLighAnim()
			light = anim.onStart.call(self)
			animations[dancerName] = anim

func _on_exited(other: Area3D) -> void:
	var interactor = other.get_parent();
	var dancer = interactor.get_parent();
	if dancer is Dancer : 
		var dancerName : String = str(dancer.name, ".",interactor.name)
		if animations.has(dancerName) and animations[dancerName].hasToBeRemovedWhenExited : 
			light = animations[dancerName].onStop.call(self)
			animations.erase(dancerName)
