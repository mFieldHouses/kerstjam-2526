extends Resource
class_name ConsoleCommand

@export_multiline var command_description : String
@export var command_name : String ##The keyword that will trigger this command.
@export var command_parameters : Array[ConsoleCommandParameter] ##Parameters for this command.[br][br]NOTE: non-optional parameters must precede optional parameters, in the exact same way the arguments for the [param target_callable] are ordered.
@export var target_autoload_name : String ##The autoload to call the [Callable] in.
@export var target_callable_name : StringName ##Name of the [Callable] to be called.
@export var close_console : bool = false ##Whether to close the console window and resume regular gameplay upon succesfull execution.
