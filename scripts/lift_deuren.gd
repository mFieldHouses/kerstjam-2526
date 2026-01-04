extends Node3D
class_name LiftDoorController

## LiftDoorController
## Liftdeuren laten openschuiven zoals echte liftdeuren (2 panelen).
##
## USAGE:
## 1) Zet dit script op: LiftDeuren (Node3D)
## 2) Sleep in de Inspector:
##    - door_left  -> LiftDeur_L
##    - door_right -> LiftDeur_R
## 3) Stel slide_distance in (meters / units) en open_time.
## 4) Roep aan:
##    - open_doors()
##    - close_doors()
##    - toggle_doors()
##
## TIP: Zet de origin/pivot van elke deur in het midden van dat paneel (meestal al ok).
##      Deuren bewegen in LOCAL space van LiftDeuren.

@export var door_left: Node3D
@export var door_right: Node3D

# Hoe ver elk paneel schuift vanaf "dicht" positie
@export var slide_distance: float = 0.55

# Richting waarin ze uit elkaar schuiven (LOCAL richting van LiftDeuren)
# Standaard: X-as links/rechts
@export var slide_axis: Vector3 = Vector3(1, 0, 0)

@export var open_time: float = 0.6
@export var close_time: float = 0.6

# Optioneel: even open blijven als je auto-close gebruikt
@export var auto_close: bool = false
@export var auto_close_delay: float = 2.0

var _closed_pos_l: Vector3
var _closed_pos_r: Vector3
var _is_open: bool = false
var _tween: Tween
var _auto_close_timer: SceneTreeTimer

func _ready() -> void:
	if door_left == null or door_right == null:
		push_warning("[LiftDoorController] Assign door_left en door_right in de Inspector.")
		return

	_closed_pos_l = door_left.position
	_closed_pos_r = door_right.position

	# Normalize axis zodat slide_distance exact klopt
	if slide_axis.length() == 0.0:
		slide_axis = Vector3(1, 0, 0)
	slide_axis = slide_axis.normalized()

func open_doors() -> void:
	if door_left == null or door_right == null:
		return
	if _is_open:
		return

	_kill_tween_and_timer()

	var open_offset := slide_axis * slide_distance
	var target_l := _closed_pos_l - open_offset
	var target_r := _closed_pos_r + open_offset

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(door_left, "position", target_l, open_time)
	_tween.parallel().tween_property(door_right, "position", target_r, open_time)
	_tween.finished.connect(func():
		_is_open = true
		if auto_close:
			_auto_close_timer = get_tree().create_timer(auto_close_delay)
			_auto_close_timer.timeout.connect(func(): close_doors())
	)

func close_doors() -> void:
	if door_left == null or door_right == null:
		return
	if not _is_open:
		return

	_kill_tween_and_timer()

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(door_left, "position", _closed_pos_l, close_time)
	_tween.parallel().tween_property(door_right, "position", _closed_pos_r, close_time)
	_tween.finished.connect(func():
		_is_open = false
	)

func toggle_doors() -> void:
	if _is_open:
		close_doors()
	else:
		open_doors()

func _kill_tween_and_timer() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null

	# Timer kun je niet "killen", maar we voorkomen dubbele triggers door referentie te laten vallen
	_auto_close_timer = null

func is_open() -> bool:
	return _is_open
