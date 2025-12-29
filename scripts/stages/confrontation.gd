extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogManager.initiate_dialog_with("confrontation1", $philip, "???", load("res://icon.svg"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
