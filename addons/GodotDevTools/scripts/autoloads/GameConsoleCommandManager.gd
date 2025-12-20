extends Node

var _commands_directory : String = "res://assets/resources/console_commands/"

var _command_list : Dictionary[String, ConsoleCommand] = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	reload_command_list()

func reload_command_list():
	GameLogger.print_as_autoload(self, "Loading commands from " + _commands_directory + "...")
	
	var dir = DirAccess.open(_commands_directory)
	if dir.get_open_error() != 0:
		GameLogger.printerr_as_autoload(self, "Could not load commands from directory " + _commands_directory)
		return
	
	for file_path in dir.get_files(): #This could cause problems in exports, read docs
		var _resource = load(_commands_directory + file_path)
		if _resource is ConsoleCommand:
			GameLogger.print_as_autoload(self, "Found and loaded command " + file_path)
			_command_list.get_or_add(_resource.command_name, _resource)
	
	GameLogger.print_as_autoload(self, "Finished loading commands")

func run_command(command_unparsed : String):
	GameLogger.print_as_autoload(self, "Player issued command \"" + command_unparsed + "\"")
	
	var _command_split : PackedStringArray = command_unparsed.split(" ")
	var _command_name : String = _command_split[0]
	if !_command_list.has(_command_name):
		GameConsole.print_line("Command not recognised: " + _command_name)
		return
	
	var _issued_command : ConsoleCommand = _command_list[_command_name]
	var _command_parameter_options : Array[ConsoleCommandParameter] = _issued_command.command_parameters
	
	var _parameters_entered : PackedStringArray = _command_split.duplicate()
	_parameters_entered.remove_at(0)
	
	var _required_parameters : Array[ConsoleCommandParameter] = []
	var _optional_parameters : Array[ConsoleCommandParameter] = []
	for _command_parameter : ConsoleCommandParameter in _command_parameter_options:
		if _command_parameter.parameter_optional:
			_optional_parameters.append(_command_parameter)
		else:
			_required_parameters.append(_command_parameter)
			
	var _casted_parameters : Array = []
	
	var idx : int = 0
	for _command_parameter : ConsoleCommandParameter in _command_parameter_options:
		if !_command_parameter.parameter_optional and idx > _parameters_entered.size() - 1:
			GameConsole.print_line("Error: command \"" + _command_name + "\" expects at least " + str(_required_parameters.size()) + " parameters but received " + str(_parameters_entered.size()))
			return
		else:
			if _command_parameter.parameter_optional and _parameters_entered.size() <= idx:
				break
			match _command_parameter.parameter_type:
				0:
					_casted_parameters.append(int(_parameters_entered[idx]))
				1:
					_casted_parameters.append(float(_parameters_entered[idx]))
				2:
					if _parameters_entered[idx] == "true" or _parameters_entered[idx] == "1":
						_casted_parameters.append(true)
					elif _parameters_entered[idx] == "false" or _parameters_entered[idx] == "0":
						_casted_parameters.append(false) 
					else:
						GameConsole.print_line("Error: parameter " + str(idx + 1) + " expects a boolean but " + _parameters_entered[idx] + " was entered")
						return
				3:
					_casted_parameters.append(_parameters_entered[idx])
				4:
					pass
		idx += 1
		
	if _issued_command.close_console:
		GameConsole.close_console()
		
	GameLogger.print_verbose_as_autoload(self, "calling function " + _issued_command.target_callable_name + " on autoload " + _issued_command.target_autoload_name + " with parameters " + str(_casted_parameters))
	get_node("/root/" + _issued_command.target_autoload_name).callv(_issued_command.target_callable_name, _casted_parameters)

#func open_help_page(command_id : String = "help"):
	#if _command_list.has(command_id):
		#GameConsole.print_line("Opening help page for command " + command_id)
		#PlayerUIState.player_fp_ui_root_instance.get_node("command_catalogue").show_catalogue(command_id)
	#else:
		#GameConsole.print_line("Help: Command " + command_id + " not found")
