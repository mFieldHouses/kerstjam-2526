extends Button

@export var stage_check_id : String
@export var stage_launch_id : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disabled = !SaveFileManager._unlocked_stages[stage_check_id]
	
	button_down.connect(SceneManager.launch_stage.bind(stage_launch_id))
