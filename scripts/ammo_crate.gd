extends Node3D

@export var held_item : ItemDescription
@export var count : int = 1

@export var is_health_pack : bool = false
@export var health_amount : float = 5.0

@onready var collision := get_node_or_null("collision")
@onready var anim_root := get_node_or_null("AnimatableBody3D")

@onready var omni_light : OmniLight3D = $OmniLight3D

func _ready() -> void:
	collision.body_entered.connect(pickup)
	
	# item guard
	if held_item == null:
		push_error("held_item is NULL")
		return
	
	$"AnimatableBody3D/Bullet-1".visible = false
	$"AnimatableBody3D/Bullet-2".visible = false
	
	# light color via item
	if held_item is AmmoItemDescription and omni_light and !is_health_pack:
		match held_item.ammo_type_identifier:
			"fast":
				omni_light.light_color = Color.hex(0x1e76c5)
				$"AnimatableBody3D/Bullet-1".visible = true
				$"AnimatableBody3D/Bullet-2".visible = true
			"big":
				omni_light.light_color = Color.hex(0xd9001f)
			"snow":
				omni_light.light_color = Color.WHITE
			_:
				pass
		
		if held_item.ammo_type_identifier != "fast":
			$AnimatableBody3D.add_child(held_item.item_model.instantiate())
	
	if is_health_pack:
		print("is health pack")
		omni_light.light_color = Color.RED
		$AnimatableBody3D.add_child(preload("res://assets/meshes/Weapons/Ammo/Health-Hart-1.glb").instantiate())
	


func pickup(body) -> void:
	if held_item == null:
		pass
	elif is_health_pack:
		if PlayerState.player_instance._health == 30.0:
			return
					
		PlayerState.player_instance._health += health_amount
	else:
		PlayerState.add_item_to_inventory(held_item, count)
		PlayerState.player_instance._play_ammo_pickup_sound()
	
	queue_free()
