extends Node

@onready var _parent : Node3D = get_parent()
var _done : bool = false

func _ready() -> void:
	if _parent is Enemy:
		_parent.freeze = true

func _process(delta: float) -> void:
	if _done:
		return
	
	if _parent.global_position.y >= PlayerState.player_instance.global_position.y + 0.2:
		_parent.position -= _parent.global_basis.z * 2
		if _parent is Enemy:
			_parent.freeze = false
		_done = true
