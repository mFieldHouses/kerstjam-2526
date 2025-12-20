extends Resource
class_name ConsoleCommandParameter

@export_multiline var parameter_description : String
@export var parameter_hint_name : String
@export var parameter_optional : bool = false
@export var parameter_default : String = ""
@export_enum("Integer", "Float", "Boolean", "String", "Object") var parameter_type : int = 0
