extends Node

@onready var _parent : Node3D = get_parent()
var _done : bool = false

func _process(delta: float) -> void:
	if _done:
		return
	
	if _parent.global_position.y >= PlayerState.player_instance.global_position.y:
		print("launch")
		_parent.position -= _parent.global_basis.z * 2
		_done = true
