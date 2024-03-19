extends Camera3D

var mouse = Vector2()

var selected = null
var Ctrled = false

# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventKey : 
		if event.is_action("ui_rotate") :
			Ctrled = event.pressed
		else : 
			if event.is_action("ui_up") and event.pressed : 
				translate_object_local(Vector3.FORWARD * 0.01)
			elif event.is_action("ui_down") and event.pressed : 
				translate_object_local(Vector3.BACK * 0.01)
	
	if event is InputEventMouse :
		mouse = event
		
	if Ctrled :
		rotate_object_local(Vector3.DOWN, mouse.relative.x * 0.01)
		rotate_object_local(Vector3.RIGHT, mouse.relative.y * 0.01)
	elif event is InputEventMouseButton :
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_selection()
			
func get_selection() :
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse.position)
	var end = project_position(mouse.position, 1000)
	var query = PhysicsRayQueryParameters3D.create(start, end)
	var result = worldspace.intersect_ray(query)
	#print(result)
	if result.has("collider"):
		if(selected != null):
			selected.unselect()
		if(selected != result.collider) :
			selected = result.collider
			selected.select()
		else : 
			selected = null
