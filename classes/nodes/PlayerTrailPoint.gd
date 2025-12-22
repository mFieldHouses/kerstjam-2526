extends Hittable
class_name PlayerTrailPoint

@onready var area : Area3D = $Area3D

signal wipe_out_from_point
signal wipe_out_this_point

func _ready() -> void:
	area.body_entered.connect(_body_entered)

func _body_entered(body : PhysicsBody3D) -> void:
	if body is Yeti:
		wipe_out_from_point.emit()
	elif body is Snowball:
		print("got hit with snowball, wipe me out")
		wipe_out_this_point.emit()

func hit(x,y,z) -> void:
	wipe_out_this_point.emit()
