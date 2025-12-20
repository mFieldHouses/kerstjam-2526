extends Module
class_name ItemContainerInterface

##Module that allows the player to interchange items with the parent [ItemContainer] using a grid interface.
##
##Requires a [CollisionShape3D] child to function as hitbox for where the interaction prompt shows.
##Cannot be siblings with [ItemContainerQuickloot].

@export var action_text : String

@export_enum("Store & Take", "Store only", "Take only") var interaction_type = 0

@export_range(0.0, 1.0, 0.01, "or_greater" ,"hide_slider") var interaction_distance_override : float = 0.0 ##If set to anything higher than 0, this value will override the standard value provided by [GlobalGameConfig].

var world_3d : World3D

var parent_item_container : ItemContainer

var interface

func _ready() -> void:
	if get_parent() is not ItemContainer:
		printerr(self, " is not a child of ItemContainer and will not function.")
	else:
		parent_item_container = get_parent()
	
	world_3d = get_parent().get_parent().get_world_3d()
	
	setup_triggers(_start_exchange)

func _start_exchange(_bogus):
	PlayerState.exchange_items(parent_item_container, 0)
