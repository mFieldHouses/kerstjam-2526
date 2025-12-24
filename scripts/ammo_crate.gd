extends Hittable

@export var held_item : ItemDescription
@export var count : int = 1

func hit(x,y,z) -> void:
	PlayerState.add_item_to_inventory(held_item, count)
	queue_free()
