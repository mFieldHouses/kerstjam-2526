extends Node3D

@export var held_item : ItemDescription
@export var count : int = 1

func _ready() -> void:
	$collision.body_entered.connect(pickup)
	
	if held_item.item_name != "Fast Ammo":
		$"AnimatableBody3D/Bullet-1".visible = false
		$"AnimatableBody3D/Bullet-2".visible = false
		var _model = held_item.item_model.instantiate()
		$AnimatableBody3D.add_child(_model)
		
		if held_item is AmmoItemDescription:
			match held_item.ammo_type_identifier:
				"fast":
					$OmniLight3D.light_color = Color.hex(0x1e76c5)
				"big":
					$OmniLight3D.light_color = Color.hex(0xd9001f)
				"explode":
					pass
				"snow":
					$OmniLight3D.light_color = Color.WHITE
	

func pickup(x) -> void:
	PlayerState.add_item_to_inventory(held_item, count)
	queue_free()
