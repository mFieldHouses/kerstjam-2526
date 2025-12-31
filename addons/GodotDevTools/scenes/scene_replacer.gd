@tool
extends Window

var _has_node_selected : bool = false

signal replace_scenes(parent_node : Node, path : String, substitute_path : String, copy_transforms : bool, remove : bool, recursive : bool)

func _ready() -> void:
	$MarginContainer/VBoxContainer/HBoxContainer/cancel.button_down.connect(queue_free)

func _process(delta: float) -> void:
	_has_node_selected = EditorInterface.get_selection().get_selected_nodes().size() != 0
	
	var _allow_replace : bool = _has_node_selected and $MarginContainer/VBoxContainer/path.text != "" and ($MarginContainer/VBoxContainer/substitute_path.text != "" or $MarginContainer/VBoxContainer/remove.button_pressed)
	
	$MarginContainer/VBoxContainer/HBoxContainer/replace.disabled = !_allow_replace
	$MarginContainer/VBoxContainer/please_select_node.visible = !_has_node_selected
	$MarginContainer/VBoxContainer/substitute_path.editable = !$MarginContainer/VBoxContainer/remove.button_pressed

func _on_replace_button_down() -> void:
	replace_scenes.emit(
		EditorInterface.get_selection().get_selected_nodes()[0],
		$MarginContainer/VBoxContainer/path.text,
		$MarginContainer/VBoxContainer/substitute_path.text,
		$MarginContainer/VBoxContainer/copy_transforms.button_pressed,
		$MarginContainer/VBoxContainer/remove.button_pressed,
		$MarginContainer/VBoxContainer/recursive.button_pressed
	)
