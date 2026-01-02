extends Node3D

var _was_empty : bool = true

signal player_entered

func _process(delta: float) -> void:
	var _is_hit : int = get_node("hit").is_colliding()
	
	if _was_empty and _is_hit:
		player_entered.emit()
	
	_was_empty = !_is_hit
		
