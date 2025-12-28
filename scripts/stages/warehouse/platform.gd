extends Node3D

var _light_energy_mult : float = 0.2
var _light_timer : float = 0.0
var _light_blink_speed : float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ActionPromptTrigger.trigger.connect(_trigger)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_light_timer += delta
	for _light : OmniLight3D in $lights.get_children():
		_light.light_energy = ((sin(_light_timer * _light_blink_speed) + 1.0) / 0.5) * _light_energy_mult

func _trigger(x) -> void:
	$lights.visible = true
	
	var _move_tween : Tween = create_tween()
	_move_tween.tween_property(self, "position:y", -50, 60) #sequence van een minuut 
