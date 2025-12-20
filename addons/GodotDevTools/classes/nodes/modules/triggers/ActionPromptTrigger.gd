extends Trigger
class_name ActionPromptTrigger

##A class that provides the parent node with a simple prompt for the player to interact with. When the required action or key is pressed, this node will emit [signal trigger].

##Needs to have an [Area3D] with a [CollisionShape3D] as a child to function.

@export_enum("Screenbound", "Spacebound") var display_mode : int = 0 ##Currently does nothing. To be implemented later.

@export_enum("Single", "Multi-State") var mode : int = 0 ##Determines whether the prompt changes after triggering. [param Single] disables this behavior, and [param Multi-State] allows you to set an array that the prompt cycles through.
@export var multi_state_list : Array[String]
@export var multi_state_index : int = 0 ##Only change this if the starting state is an exception from the default, like a door being open upon load time.

@export var prompt_prefix : String = "Interact" ##The action the player would perform, like "Open", "Talk with" etc. Will be written in regular font.
@export var prompt_subject : String = "" ##The subject of the action, like "Button", "Door", "<NPC name>" etc. Will be written in bold font.
@export var prompt_suffix : String = "" ##Any additional text after the subject. Will be written in regular font.
@export var trigger_action : String = "interact" ##Action, as named in project settings, that will emit [signal trigger].
@export var trigger_key : String = "" ##If set, will overwrite trigger_action with this specific key.
@export var override_interaction_distance : float = 0 ##Setting this to anything else than 0 will overwrite the standard interaction distance set by [GlobalGameDefaults].

@onready var _areas : Array[Area3D] = get_area_3ds()

var _show_prompt : bool = false: ##Determines whether the prompt is visible in UI and whether this trigger can be activated.
	set(x):
		_show_prompt = x
		if x == true and enabled:
			PlayerUIState.set_prompt(Utility.get_action_key(trigger_action), get_prefix_text(), prompt_subject, prompt_suffix, true)
		else:
			PlayerUIState.set_prompt("", "", "", "",false)
		

func get_prefix_text() -> String:
	if mode == 0:
		return prompt_prefix
	else:
		return multi_state_list[multi_state_index % multi_state_list.size()]


func _input(event: InputEvent) -> void:
	if _show_prompt and !PlayerState.is_sleeping:
		if event.is_action(trigger_action) and event.is_pressed() and enabled:
			get_viewport().set_input_as_handled()
			trigger.emit(Utility.get_action_key(trigger_action))
			
			multi_state_index += 1
			_show_prompt = true #Update prompt text


func _ready() -> void:
	if _areas == []:
		no_area_3ds_error()


func _process(delta: float) -> void:
	if player_looking_at_area():
		if PlayerState.get_distance_to_player(global_position) <= GlobalGameDefaults.standard_interaction_range:
			if _show_prompt == false:
				_show_prompt = true
		else:
			_show_prompt == false
	elif _show_prompt == true:
		_show_prompt = false
		

func player_looking_at_area() -> bool: ##Returns whether the player is looking at any of the areas added as children to this [ActionPromptTrigger].
	var player_looking_at = PlayerState.layer_5_raycast.get_collider()
	
	for area in _areas:
		if area == player_looking_at:
			return true
	
	return false
