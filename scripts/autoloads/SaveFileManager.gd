extends Node

var _unlocked_stages : Dictionary = {
	"introduction": true,
	"yeti_chase": false,
	"to_warehouse": false,
	"warehouse_1": false,
	"warehouse_2": false,
	"confrontation": false
}

var _save_data : Dictionary

signal done_saving

func _ready() -> void:
	save_game()
	
	_unlocked_stages = retrieve_save_data()["unlocked_stages"]

func save_game() -> void:
	DirAccess.make_dir_absolute("user://savedata")
	
	var _fa : FileAccess = FileAccess.open("user://savedata/save.json", FileAccess.WRITE_READ)
	var _json : JSON = JSON.new()
	
	var _save_obj : Dictionary = {
		"unlocked_stages": _unlocked_stages,
		"configurable_values": ConfigurableValues.get_save_data()
	}
	
	_fa.store_string(_json.stringify(_save_obj, "  "))
	
	#done_saving.emit()
	

func retrieve_save_data() -> Dictionary:
	if _save_data:
		return _save_data
	
	var _fa : FileAccess = FileAccess.open("user://savedata/save.json", FileAccess.READ)
	var _json : JSON = JSON.new()
	
	_json.parse(_fa.get_as_text())
	
	_save_data = _json.data
	return _save_data
