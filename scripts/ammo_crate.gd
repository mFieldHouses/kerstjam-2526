extends Node3D

@export var held_item : ItemDescription
@export var count : int = 1

func _ready() -> void:
	$collision.body_entered.connect(pickup)

func pickup(x) -> void:
	PlayerState.add_item_to_inventory(held_item, count)
	queue_free()
