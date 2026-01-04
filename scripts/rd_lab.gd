extends Node3D

func open_roof() -> void:
	$"RD-1/AnimationPlayer".play("Animation", -1, 0.2)
