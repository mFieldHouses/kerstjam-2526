extends Trigger
class_name AreaTrigger

##A class that triggers based on whether anything is within a certain distance to it.

##Requires an [Area3D] as a child. Any [Character] within this range will fire this trigger.

@export var trigger_distance : float = 0

@onready var _areas : Array[Area3D] = get_area_3ds()

var _triggered : bool = false

func _process(delta: float) -> void:
	if !enabled:
		return
	
	if _areas == []:
		no_area_3ds_error()
	
	if anything_in_areas():
		if _triggered == false:
			_triggered = true
			toggle.emit("E", true)
	else:
		if _triggered == true:
			_triggered = false
			toggle.emit("E", false)


func anything_in_areas() -> bool:
	for area in _areas:
		if area.get_overlapping_bodies().size() > 0:
			return true
	
	return false
