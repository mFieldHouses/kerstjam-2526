@tool
extends Window

var _selected_template_id : int = 0

var _selected_device_part_category : int = 10
var _selected_device_part_subcategory : String = ""
var _selected_device_part_custom_subcategory : String = ""

signal create_item(template : int, item_name : String, args : Array)

func _ready() -> void:
	$Control/MarginContainer/VBoxContainer/template.get_popup().id_pressed.connect(select_template_category)
	$Control/MarginContainer/VBoxContainer/template_options/device_part/part_category.get_popup().id_pressed.connect(func(x): _selected_device_part_category = x)
	$Control/MarginContainer/VBoxContainer/template_options/device_part/subcat.text_changed.connect(func(x): _selected_device_part_subcategory = x)
	$Control/MarginContainer/VBoxContainer/template_options/device_part/custom_cat.text_changed.connect(func(x): _selected_device_part_custom_subcategory = x)
	
func _process(delta: float) -> void:
	$Control/MarginContainer/VBoxContainer/create.disabled = $Control/MarginContainer/VBoxContainer/name.text == "" or _selected_template_id == 0

func select_template_category(id : int) -> void:
	_selected_template_id = id
	
	$Control/MarginContainer/VBoxContainer/template_options/simple_item.visible = false
	$Control/MarginContainer/VBoxContainer/template_options/component.visible = false
	$Control/MarginContainer/VBoxContainer/template_options/device_part.visible = false
	
	match id:
		1:
			$Control/MarginContainer/VBoxContainer/template_options/simple_item.visible = true
		2:
			$Control/MarginContainer/VBoxContainer/template_options/component.visible = true
		3:
			$Control/MarginContainer/VBoxContainer/template_options/device_part.visible = true


func _on_create_button_down() -> void:
	var args : Array = []
	
	args.append($Control/MarginContainer/VBoxContainer/start_editing.button_pressed)
	
	match _selected_template_id:
		3:
			args.append(_selected_device_part_category)
			args.append(_selected_device_part_subcategory)
			args.append(_selected_device_part_custom_subcategory)
			args.append($Control/MarginContainer/VBoxContainer/template_options/device_part/create_scene.button_pressed)
	
	create_item.emit(_selected_template_id, $Control/MarginContainer/VBoxContainer/name.text, args)
