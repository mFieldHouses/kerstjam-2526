extends Node3D

@export var held_item : ItemDescription
@export var count : int = 1

# Kies per geplakte pickup in de inspector
@export_enum("Bullets-Blue", "Rocket-Yellow", "None") var ammo_visual := "Bullets-Blue"

@onready var collision := get_node_or_null("collision")
@onready var anim_root := get_node_or_null("AnimatableBody3D-GlobeMoving")

var ammo_types_root : Node3D = null
var omni_light : OmniLight3D = null

func _ready() -> void:
	# collision
	if collision:
		collision.body_entered.connect(pickup)
	else:
		push_error("Missing node: collision")
		return

	# anim root
	if anim_root:
		ammo_types_root = anim_root.get_node_or_null("AmmoTypes")
		omni_light = anim_root.get_node_or_null("OmniLight3D")
	else:
		push_error("Missing node: AnimatableBody3D-GlobeMoving")
		return

	# visuals
	_apply_ammo_visual()

	# item guard
	if held_item == null:
		push_error("held_item is NULL")
		return

	# light color via item
	if held_item is AmmoItemDescription and omni_light:
		match held_item.ammo_type_identifier:
			"fast":
				omni_light.light_color = Color.hex(0x1e76c5)
			"big":
				omni_light.light_color = Color.hex(0xd9001f)
			"snow":
				omni_light.light_color = Color.WHITE
			_:
				pass

func _apply_ammo_visual() -> void:
	if ammo_types_root == null:
		return

	# alles uit
	for c in ammo_types_root.get_children():
		if c is Node3D:
			c.visible = false

	# gekozen aan
	if ammo_visual == "None":
		return

	var chosen := ammo_types_root.get_node_or_null(ammo_visual)
	if chosen:
		chosen.visible = true

func pickup(body) -> void:
	if held_item == null:
		return
	PlayerState.add_item_to_inventory(held_item, count)
	queue_free()
