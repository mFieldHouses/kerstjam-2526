extends Module
class_name Trigger

@export var enabled : bool = true

signal trigger(action : String) ##Emitted when this action prompt is activated by triggering the right action or pressing the right key.
signal toggle(action : String, state : bool)

func no_area_3ds_error():
	printerr(self, " has no Area3D as child and will not function.")
