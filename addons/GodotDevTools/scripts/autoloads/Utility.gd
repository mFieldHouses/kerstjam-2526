@tool
extends Node

var debug_material : StandardMaterial3D = load("res://addons/GodotDevTools/resources/materials/debug_mat.tres")

func int_to_bin(x : int, byte_length : int) -> Array: ##Returns an array of bits representing the value of x converted to binary in big-endian
	var output = []
	output.resize(4)
	output.fill(0)
	
	if x == 0:
		return output
	
	var idx = 0
	while x > 0:
		output[idx] = x % 2
		x /= 2
		idx += 1
	
	return output

func ints_to_bitmask(ints : Array[int]):
	pass

func get_action_key(action_name : StringName):
	return OS.get_keycode_string(InputMap.action_get_events(action_name)[0].physical_keycode)

func get_keycode_string(keycode : int) -> String:
	return OS.get_keycode_string(keycode)

func get_mouse_button_string(mouse_button_index : int) -> String:
	match mouse_button_index:
		MOUSE_BUTTON_LEFT:
			return "Left Mouse Button"
		MOUSE_BUTTON_MIDDLE:
			return "Middle Mouse Button"
		MOUSE_BUTTON_RIGHT:
			return "Right Mouse Button"
		MOUSE_BUTTON_WHEEL_UP:
			return "Mouse Wheel Up"
		MOUSE_BUTTON_WHEEL_DOWN:
			return "Mouse Wheel Down"
		_:
			return "undefined"

func visualise_point(point : Vector3, root_node_3d : Node3D, delay_time : float = -1.0):
	var new_visualiser_mesh = BoxMesh.new()
	new_visualiser_mesh.size = Vector3(0.2, 2.0, 0.2)
	new_visualiser_mesh.material = debug_material
	
	var new_mesh_instance = MeshInstance3D.new()
	new_mesh_instance.mesh = new_visualiser_mesh
	
	root_node_3d.add_child(new_mesh_instance)
	new_mesh_instance.position = point
	
	var new_label = Label3D.new()
	new_label.text = str(point * 2.0)
	new_label.no_depth_test = true
	new_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	new_label.position = Vector3(0.0, 1.0, 0.0)
	new_label.fixed_size = true
	new_label.pixel_size = 0.001
	
	new_mesh_instance.add_child(new_label)
	
	if delay_time != -1.0:
		await get_tree().create_timer(delay_time).timeout
		new_mesh_instance.queue_free()


func visualise_signal_connection(_signal : Signal, _target_callable : Callable) -> void:
	var _origin_3d_obj : Node3D = _signal.get_object()
	var _target_3d_obj : Node3D = _target_callable.get_object()
	
	while _origin_3d_obj != Node3D:
		pass
		


func get_children_of_type(node : Node, type : String) -> Array[Node]:
	var result : Array[Node] = []
	
	for child in node.get_children():
		if child.get_class() == type:
			result.append(child)
	
	return result

func get_children_of_type_recursive(node : Node, type : String) -> Array[Node]:
	var result : Array[Node] = []
	
	for child in get_children_recursive(node):
		if child.get_class() == type:
			result.append(child)
	
	return result

func get_children_recursive(node : Node) -> Array[Node]:
	var _result : Array[Node] = []
	var _children_to_be_checked : Array[Node] = []
	
	for _child in node.get_children():
		_children_to_be_checked.append(_child)
	
	while _children_to_be_checked.size() > 0:
		var _child_to_check : Node = _children_to_be_checked[0]
		for _subchild in _child_to_check.get_children():
			_children_to_be_checked.append(_subchild)
		
		_result.append(_child_to_check)
		_children_to_be_checked.erase(_child_to_check)
	
	return _result

func remove_all_children_of_node(node : Node):
	for child in node.get_children():
		child.queue_free()

func get_relative_transform(target: Node3D, reference: Node3D) -> Transform3D:
	return reference.global_transform.affine_inverse() * target.global_transform
