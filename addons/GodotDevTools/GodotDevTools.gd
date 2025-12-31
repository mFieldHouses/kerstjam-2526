@tool
extends EditorPlugin

var parameters_plugin

var previous_item_action_binding_property_list

var _create_item_button : Button

func _enter_tree() -> void:
	_create_item_button = preload("res://addons/GodotDevTools/scenes/create_item_button.tscn").instantiate()
	
	add_tool_menu_item("Create item...", _open_item_creation_menu)
	add_tool_menu_item("Replace Scenes...", _open_scene_replacement_menu)
	
	var _add_action_prompt_button : Button = Button.new()
	_add_action_prompt_button.text = "Setup action prompt for object"
	_add_action_prompt_button.button_down.connect(_setup_action_prompt_for_object)
	_add_action_prompt_button.flat = true
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _add_action_prompt_button)
	
	
func _open_item_creation_menu() -> void:
	var _new_menu : Window = preload("res://addons/GodotDevTools/scenes/item_creation.tscn").instantiate()
	_new_menu.close_requested.connect(func(): _new_menu.queue_free())
	
	add_child(_new_menu)
	_new_menu.popup_centered(Vector2i(350,450))
	_new_menu.create_item.connect(_create_item)
	_new_menu.create_item.connect(func(x,y,z): _new_menu.queue_free())


func _create_item(template : int, item_name : String, args : Array) -> void:
	pass
			

func get_category_name_by_id(id : int) -> String:
	match id:
		0:
			return "frames_casings"
		1:
			return "grips_handles"
		2:
			return "modules"
		3:
			return "miscellaneous"
		_:
			return "error"



func _process(delta: float) -> void:
	pass

func _exit_tree() -> void:
	remove_tool_menu_item("Create item...")
	remove_tool_menu_item("Replace Scenes...")

func _setup_action_prompt_for_object() -> void:
	var _object = EditorInterface.get_selection().get_selected_nodes()[0]
	if _object is not VisualInstance3D:
		_object = Utility.get_children_of_type(_object, "MeshInstance3D")[0]
	
	var _aabb : AABB = _object.get_aabb()
	
	var _apt : ActionPromptTrigger = ActionPromptTrigger.new()
	_object.add_child(_apt)
	_apt.owner = EditorInterface.get_edited_scene_root()
	var _area3d : Area3D = Area3D.new()
	_area3d.collision_layer = 2
	_apt.add_child(_area3d)
	_area3d.owner = EditorInterface.get_edited_scene_root()
	var _cls : CollisionShape3D = CollisionShape3D.new()
	var _boxmesh : BoxShape3D = BoxShape3D.new()
	_boxmesh.size = _aabb.size
	_cls.shape = _boxmesh
	_area3d.add_child(_cls)
	_cls.owner = EditorInterface.get_edited_scene_root()
	
func _open_scene_replacement_menu() -> void:
	var _new_menu : Window = preload("res://addons/GodotDevTools/scenes/scene_replacer.tscn").instantiate()
	_new_menu.close_requested.connect(func(): _new_menu.queue_free())
	
	add_child(_new_menu)
	_new_menu.popup_centered(Vector2i(400,450))
	_new_menu.replace_scenes.connect(_replace_scenes)

func _replace_scenes(parent_node : Node, path : String, substitute_path : String, copy_transforms : bool = true, remove : bool = false, recursive : bool = false) -> void:
	var _nodes_to_check : Array[Node]
	
	if recursive:
		_nodes_to_check = Utility.get_children_recursive(parent_node)
	else:
		_nodes_to_check = parent_node.get_children()
	
	for _child in _nodes_to_check:
		if _child.scene_file_path == path:
			var _transform : Transform3D
			var _pos
			if _child is Node3D:
				_transform = _child.global_transform
				_pos = _child.position
			if _child is Node2D:
				_pos = _child.position
				
			_child.queue_free()
			
			if remove:
				continue
			
			var _new_scene : Node = load(substitute_path).instantiate()
			parent_node.add_child(_new_scene)
			
			if _new_scene is Node2D or _new_scene is Node3D:
				_new_scene.position = _pos
			
			if _new_scene is Node3D and copy_transforms:
				_new_scene.global_transform = _transform
