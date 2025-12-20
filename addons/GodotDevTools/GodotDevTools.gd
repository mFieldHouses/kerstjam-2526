@tool
extends EditorPlugin

var parameters_plugin

var previous_item_action_binding_property_list

var _create_item_button : Button

func _enter_tree() -> void:
	_create_item_button = preload("res://addons/GodotDevTools/scenes/create_item_button.tscn").instantiate()
	
	add_tool_menu_item("Create item...", _open_item_creation_menu)
	
	
func _open_item_creation_menu() -> void:
	var _new_menu : Window = preload("res://addons/GodotDevTools/scenes/item_creation.tscn").instantiate()
	_new_menu.close_requested.connect(func(): _new_menu.queue_free())
	
	add_child(_new_menu)
	_new_menu.popup_centered(Vector2i(350,450))
	_new_menu.create_item.connect(_create_item)
	_new_menu.create_item.connect(func(x,y,z): _new_menu.queue_free())


func _create_item(template : int, item_name : String, args : Array) -> void:
	match template:
		3:
			var new_item_resource : DevicePartItemDescription = DevicePartItemDescription.new()
			new_item_resource.category = args[1]
			new_item_resource.part_subcategory = args[2]
			new_item_resource.part_custom_category = args[3]
			new_item_resource.item_category = GlobalEnums.ItemCategory.PART
			new_item_resource.item_name = item_name.to_snake_case()
			
			if args[4] == true: #whether we should also immediately create a device part scene
				var new_scene_root : Node3D = Node3D.new()
				var new_packed_scene : PackedScene = PackedScene.new()
				var scene_save_path : String = "res://assets/scenes/device_parts/" + get_category_name_by_id(args[1]) + "/" + item_name.to_snake_case() + ".tscn"
				
				new_scene_root.name = item_name
				new_packed_scene.pack(new_scene_root)
				ResourceSaver.save(new_packed_scene, scene_save_path)
				
				if args[0] == true:
					EditorInterface.open_scene_from_path(scene_save_path)
				
				new_item_resource.part_model_scene = load(scene_save_path)
			
			var resource_path : String = "res://assets/resources/items/device_parts/" + get_category_name_by_id(args[1]) + "/" + item_name.to_snake_case() + ".tres"
			ResourceSaver.save(new_item_resource, resource_path)
			if args[0] == true: #whether we should start editing the resource and scene right away
				EditorInterface.edit_resource(new_item_resource)
				EditorInterface.select_file(resource_path)
			

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
	var edited_object = EditorInterface.get_inspector().get_edited_object()
	if edited_object is ItemModelPropertyBindings:
		var property_value_list = []
		for property in edited_object.get_property_list():
			property_value_list.append(edited_object.get(property.name))
		
		if previous_item_action_binding_property_list:
			if previous_item_action_binding_property_list != property_value_list:
				edited_object.emit_changed()
		
		previous_item_action_binding_property_list = property_value_list


func _exit_tree() -> void:
	remove_tool_menu_item("Create item...")
