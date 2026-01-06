extends Node

var _flags : Array[String] = []

func has_flag(flag : String) -> bool:
	return _flags.has(flag)

func get_flags() -> Array[String]:
	return _flags

func add_flag(flag : String) -> void:
	if !_flags.has(flag):
		_flags.append(flag)

func remove_flag(flag : String) -> void:
	if _flags.has(flag):
		_flags.erase(flag)
