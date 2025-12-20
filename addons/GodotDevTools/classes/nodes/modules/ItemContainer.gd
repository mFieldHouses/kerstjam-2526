extends Module
class_name ItemContainer

##Module that keeps track of an ordered volume of items.

@export var max_weight : float = 20.0 ##In kilograms.
@export var owner_character : int
@export var owner_faction : Faction

var items : Array = [load("res://assets/resources/items/henk.tres"), load("res://assets/resources/items/henk.tres"), load("res://assets/resources/items/henk.tres")]

func get_parent_object_position() -> Vector3:
	return get_parent().position
