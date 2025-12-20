extends Resource
class_name ActionPropertyBindingPropertyModifier

##Class used to define how an [ActionPropertyBinding] resource modifies the property of the object it's bound to.

@export_enum("Number", "Boolean", "String", "Callable") var type : int = 0 

@export var mode : int = 0
@export var use_alt_values_when_untriggered : bool = false

@export var number_value : float = 1
@export var alt_number_value : float = 0
@export var boolean_value : bool = true
@export var alt_boolean_value : bool = false
@export var string_value : String = "Hello, world!"
@export var alt_string_value : String = "Goodbye, world..."
@export var callable : StringName
