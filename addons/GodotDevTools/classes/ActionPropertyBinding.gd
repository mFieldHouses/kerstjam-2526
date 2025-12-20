@tool
extends Resource
class_name ActionPropertyBinding

##Class for describing what action combinations will have what effects on whatever script this resource is somehow attached to.

@export var keys : Array[int] ##The keys/mouse buttons that need to be simultaneously activated to trigger this action.
@export var mouse_buttons : Array[int] ##The keys/mouse buttons that need to be simultaneously activated to trigger this action.
@export var item_must_be_selected : bool = true ##Whether this action will only activate when the item is selected by the player.
@export var oneshot : bool = true ##Whether the action needs to be released before it can be activated again.
@export_enum("Disabled", "Normal", "Alt") var trigger_on_unpress : int = 0 ##Only applies when [param oneshot] is [param true].[br][br]Whether this binding should apply the normal/alt value when the action becomes unpressed, or is "let go".
@export var property_modifier : ActionPropertyBindingPropertyModifier ##Defining any of the following keys will define what effect this action has on the edited object upon trigger. Multiple of these can be defined at the same time. "property_num": {"mode":"change_add/change_mult/set", "value":#}   "property_bool": {"mode":"set/toggle", "value":true/false}   "property_string": {"mode":"set/append/prepend/popf/popb", "value":"string"}   "callable": {"name":"string"}
@export var target_name : String = "x" ##The name of the to be edited property or the to be called callable.
