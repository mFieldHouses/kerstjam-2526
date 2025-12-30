extends Control

var _init_health_label_pos : Vector2 = Vector2.ZERO
var _health_shake_fac : float = 0.0
var _health_shake_fac_mod : float = 0.0

func _ready() -> void:
	_init_health_label_pos = $MarginContainer/health_left.position

func _process(delta: float) -> void:
	$MarginContainer/health_left.position = _init_health_label_pos + (Vector2(randf_range(-10, 10), randf_range(-10, 10)) * (_health_shake_fac + _health_shake_fac_mod))
	
func set_prompt(key : String, prefix : String = "", subject : String = "", suffix : String = "", show : bool = true):
	if key != "":
		$prompt_label.text = key + ") " + prefix + " [b]" + subject + "[/b] " + suffix
	
	if show:
		show_prompt()
	else:
		hide_prompt()

func show_prompt():
	var fade_tween = create_tween()
	Color(1,1,1,0)
	fade_tween.tween_property($prompt_label, "modulate", Color(1,1,1,1), 0.075)

func hide_prompt():
	var fade_tween = create_tween()
	Color(1,1,1,1)
	fade_tween.tween_property($prompt_label, "modulate", Color(1,1,1,0), 0.075)

func toggle_inventory(state : bool = true):
	$inventory.visible = state

func _die_prompt() -> void:
	$weapon_viewport.visible = false
	$you_died.visible = true

func _dmg_animation() -> void:
	var _fac_tween : Tween = create_tween()
	_health_shake_fac_mod = 0.5
	_fac_tween.tween_property(self, "_health_shake_fac_mod", 0.0, 0.2)
	
	var _alpha_tween : Tween = create_tween()
	$MarginContainer/health_left/ColorRect.modulate.a = 1.0
	_alpha_tween.tween_property($MarginContainer/health_left/ColorRect, "modulate:a", 0.0, 0.2)
