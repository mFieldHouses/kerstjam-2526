extends Hittable
class_name PlayerTrailPoint

@onready var area : Area3D = $Area3D

signal wipe_out_from_point
signal wipe_out_this_point

func _ready() -> void:
	area.area_entered.connect(_area_entered)

func _area_entered(area : Area3D) -> void:
	if area.get_parent() is Yeti:
		wipe_out_from_point.emit()
	elif area.get_parent() is Snowball:
		print("got hit with snowball, wipe me out")
		wipe_out_this_point.emit()

func hit(x,y,z) -> void:
	wipe_out_this_point.emit()
