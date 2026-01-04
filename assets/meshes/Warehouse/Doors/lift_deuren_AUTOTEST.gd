extends Node3D

## LiftDoorAutoTest
## Test of je deuren daadwerkelijk schuiven, zonder input of triggers.
##
## USAGE:
## 1) Attach op LiftDeuren (Node3D)
## 2) Assign:
##    - door_left  -> LiftDeur_L
##    - door_right -> LiftDeur_R
## 3) Run scene -> deuren openen/sluiten automatisch.
##
## Als je niks ziet:
## - check slide_axis (meestal Vector3(1,0,0))
## - check slide_distance (bijv 0.5)
## - check dat je links/rechts nodes echt Node3D zijn en niet per ongeluk Mesh resource
## - check dat je deuren niet geparent zijn op een vreemd geschaalde node

@export var door_left: Node3D
@export var door_right: Node3D

@export var slide_distance: float = 0.6
@export var slide_axis: Vector3 = Vector3(1, 0, 0)

@export var open_time: float = 0.6
@export var hold_open: float = 1.0
@export var close_time: float = 0.6
@export var hold_closed: float = 1.0

@export var debug_print: bool = true

var _closed_l: Vector3
var _closed_r: Vector3
var _tween: Tween
var _is_open: bool = false

func _ready() -> void:
	if door_left == null or door_right == null:
		push_error("[LiftDoorAutoTest] Assign door_left & door_right in Inspector.")
		return

	_closed_l = door_left.position
	_closed_r = door_right.position

	if slide_axis.length() == 0.0:
		slide_axis = Vector3(1, 0, 0)
	slide_axis = slide_axis.normalized()

	if debug_print:
		print("[LiftDoorAutoTest] closed L:", _closed_l, " R:", _closed_r)

	_loop()

func _loop() -> void:
	# open
	_open_once()
	await get_tree().create_timer(open_time + hold_open).timeout

	# close
	_close_once()
	await get_tree().create_timer(close_time + hold_closed).timeout

	_loop()

func _open_once() -> void:
	_kill_tween()

	var off := slide_axis * slide_distance
	var target_l := _closed_l - off
	var target_r := _closed_r + off

	if debug_print:
		print("[LiftDoorAutoTest] OPEN -> L:", target_l, " R:", target_r, " axis:", slide_axis, " dist:", slide_distance)

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(door_left, "position", target_l, open_time)
	_tween.parallel().tween_property(door_right, "position", target_r, open_time)

	_is_open = true

func _close_once() -> void:
	_kill_tween()

	if debug_print:
		print("[LiftDoorAutoTest] CLOSE -> L:", _closed_l, " R:", _closed_r)

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(door_left, "position", _closed_l, close_time)
	_tween.parallel().tween_property(door_right, "position", _closed_r, close_time)

	_is_open = false

func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
