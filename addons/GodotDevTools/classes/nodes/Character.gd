extends CharacterBody3D
class_name Character

##Base class describing characters that can interact with the game world and other characters.

var _inventory : Dictionary[ItemDescription, int] = {}

func get_inventory() -> Dictionary[ItemDescription, int]:
	return _inventory

func get_inventory_category(category : int) -> Dictionary[ItemDescription, int]:
	var result : Dictionary[ItemDescription, int] = {}
	for item in _inventory:
		if item.item_category == category:
			result.get_or_add(item, _inventory[item])
	
	return result

func add_items_to_inventory(items : Dictionary[ItemDescription, int]) -> void:
	for item_desc in items:
		if _inventory.has(item_desc):
			_inventory[item_desc] += items[item_desc]
		else:
			_inventory.get_or_add(item_desc, items[item_desc])

func remove_items_from_inventory(items : Dictionary[ItemDescription, int]) -> void:
	for item_desc in items:
		_inventory[item_desc] -= items[item_desc]
		if _inventory[item_desc] <= 0:
			_inventory.erase(item_desc)
