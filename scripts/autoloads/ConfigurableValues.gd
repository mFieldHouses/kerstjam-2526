extends Node

##Autoload that manages values that can be configured by the player

##Export values are not used directly, but to instruct the settings panel what to display

@export_group("Controls")
@export_range(0.1, 3.0, 0.01) var mouse_sensitivity : float = 1.0
@export_range(0.1, 3.0, 0.01) var weapon_selection_scroll_sensitivity : float = 1.0
var invert_weapon_selection_scroll : bool = false

@export_group("Visual")
@export_range(30, 170, 0.1) var fov : float = 75.0
var low_graphics_mode : bool = false

@export_group("Audial")
@export_range(0.1, 5.0, 0.01) var environment_volume : float = 1.0
@export_range(0.1, 5.0, 0.01) var sfx_volume : float = 1.0
@export_range(0.1, 5.0, 0.01) var music_volume : float = 1.0

func _ready() -> void:
	var _save_data : Dictionary = SaveFileManager.retrieve_save_data()
	
	if !_save_data.has("configurable_values"):
		return
	
	for _prop : String in _save_data["configurable_values"]:
		set(_prop, _save_data["configurable_values"][_prop])


func get_save_data() -> Dictionary:
	var _obj : Dictionary = {}
	
	for _prop : Dictionary in get_property_list():
		if _prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE: #all variables in this autoload will be saved
			_obj.get_or_add(_prop.name, get(_prop.name))
	
	return _obj


func get_configurable_values() -> Dictionary[String, Array]:
	var _result : Dictionary[String, Array] = {}
	
	#print(get_property_list())
	
	for _prop : Dictionary in get_property_list():
		if (_prop.usage & PROPERTY_USAGE_GROUP):
			_result.get_or_add(_prop.name, [])
	
	var _group_cursor : String = ""
	for _prop : Dictionary in get_property_list():
		if (_prop.usage & PROPERTY_USAGE_GROUP):
			_group_cursor = _prop.name
		elif (_prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE):
			_result[_group_cursor].append(_prop)
	
	var _cpy = _result.duplicate()
	for _group in _cpy:
		if _result[_group].size() == 0:
			_result.erase(_group)
	
	return _result
