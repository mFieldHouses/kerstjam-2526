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
