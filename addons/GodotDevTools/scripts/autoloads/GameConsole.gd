extends Node

signal console_toggled(state : bool)
signal line_printed(message : String)

var console_open : bool = false
var open_console_key = KEY_F1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func print_line(message : String) -> void:
	line_printed.emit(message)
	GameLogger.print_verbose_as_autoload(self, "Line printed: " + message)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == open_console_key and event.is_pressed():
			if console_open:
				close_console()
			else:
				open_console()
		
		elif event.keycode == KEY_ESCAPE and event.is_pressed() and console_open:
			close_console()

func open_console() -> void:
	print("open console")
	console_toggled.emit(true)
	console_open = true

func close_console() -> void:
	console_toggled.emit(false)
	console_open = false
