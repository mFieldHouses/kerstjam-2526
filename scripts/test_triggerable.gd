extends Node3D

func _ready() -> void:
	get_children()[0].trigger.connect(test_trigger_func)

func test_trigger_func(x) -> void:
	print("I got triggered")
