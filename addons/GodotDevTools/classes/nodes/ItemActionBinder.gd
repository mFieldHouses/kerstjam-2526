extends Node
class_name ItemActionBinder

##@experimental: not all value handling has been implemented yet
##Node which sets values on its parent according to [ActionPropertyBinding]s.

@export var item_action_bindings : Array[ActionPropertyBinding]:
	set(x):
		item_action_bindings = x
		_bindings = x
		#x.changed.connect(func update_bindings(): item_action_bindings = x.item_action_bindings; print("update _bindings"))
		
var _bindings : Array :
	set(x):
		#item_action_bindings = x
		#print(item_action_bindings)
		
		_oneshot_bindings = []
		for binding in x:
			if binding.oneshot:
				_oneshot_bindings.append(false)
			else:
				_oneshot_bindings.append(null)

var _parent : Node

var _oneshot_bindings : Array = [] ##A boolean value at any index indicates that the binding at that same index in [param item_action_bindings] is a oneshot action. A <null> value indicates it isn't. When the binding is a oneshot binding, true indicates it was pressed previous frame and false indicates it wasn't.

var _mouse_scroll_buffer : Array = []

var _initialised : bool = false

func _ready() -> void:
	_parent = get_parent()
	await get_tree().create_timer(0.05).timeout
	_bindings = item_action_bindings
	
	_oneshot_bindings = []
	for binding in item_action_bindings:
		if binding.oneshot:
			_oneshot_bindings.append(false)
		else:
			_oneshot_bindings.append(null)
	
	_initialised = true

func _process(delta: float) -> void:
	if _initialised:
		var binding_idx : int = 0
		
		for binding : ActionPropertyBinding in item_action_bindings:
			var binding_triggered : int = is_binding_triggered(binding)
			
			if binding.oneshot:
				if !binding_triggered:
					if _oneshot_bindings[binding_idx] == true:
						match binding.trigger_on_unpress:
							1:
								apply_value(binding, binding.property_modifier.number_value, binding.property_modifier.boolean_value, binding.property_modifier.string_value, binding.property_modifier.callable)
							2:
								apply_value(binding, binding.property_modifier.alt_number_value, binding.property_modifier.alt_boolean_value, binding.property_modifier.alt_string_value, binding.property_modifier.callable)
						
					_oneshot_bindings[binding_idx] = false
					continue #cut off loop here
				
				else:
					if _oneshot_bindings[binding_idx] == false:
						apply_value(binding, binding.property_modifier.number_value, binding.property_modifier.boolean_value, binding.property_modifier.string_value, binding.property_modifier.callable)
						_oneshot_bindings[binding_idx] = true
				
				binding_triggered = binding_triggered && !_oneshot_bindings[binding_idx]
			
			else:
				if !binding_triggered:
					if binding.property_modifier:
						if binding.property_modifier.use_alt_values_when_untriggered:
							apply_value(binding, binding.property_modifier.alt_number_value, binding.property_modifier.alt_boolean_value, binding.property_modifier.alt_string_value, binding.property_modifier.callable)
				
					binding_idx += 1
					continue #cut off loop here
				
				if binding.property_modifier:
					apply_value(binding, binding.property_modifier.number_value, binding.property_modifier.boolean_value, binding.property_modifier.string_value, binding.property_modifier.callable)
				
				if binding.oneshot:
					_oneshot_bindings[binding_idx] = true
			
			binding_idx += 1

func apply_value(binding : ActionPropertyBinding, num_value : float, bool_value : bool, string_value : String, callable_name : StringName):
	#print("applying value ", bool_value, " to ", binding.target_name, " (", parent.get(binding.target_name), ")")
	match binding.property_modifier.type:
		0: #number:
			match binding.property_modifier.mode:
				0: #add
					_parent.set(binding.target_name, _parent.get(binding.target_name) + num_value)
		1: #boolean
			match binding.property_modifier.mode:
				0: #toggle
					pass
				1: #set
					_parent.set(binding.target_name, bool_value)
		2: #String
			pass
		3: #Callable
				_parent.call(binding.target_name)
		#if binding.has("property_num"):
			#match binding.property_num.mode:
				#"change_add":
					#parent.set(binding.target_name, parent.get(binding.target_name) + binding.property_num.value)
				#"change_mult":
					#parent.set(binding.target_name, parent.get(binding.target_name) * binding.property_num.value)
				#"set":
					#parent.set(binding.target_name, binding.property_num.value)
		#
		#if binding.has("property_bool"):
			#match binding.property_num.mode:
				#"toggle":
					#parent.set(binding.target_name, !parent.get(binding.target_name))
				#"set":
					#parent.set(binding.target_name, binding.property_num.value)
		#
		#if binding.has("property_string"):
			#match binding.property_string.mode:
				#"set":
					#parent.set(binding.target_name, binding.property_string.value)
				#"append":
					#parent.set(binding.target_name, parent.get(binding.target_name).join(PackedStringArray([binding.property_string.value])))
				#"prepend":
					#parent.set(binding.target_name, binding.property_string.value.join(PackedStringArray([parent.get(binding.target_name)])))
				#"popf":
					#parent.set(binding.target_name, parent.get(binding.target_name).lstrip(parent.get(binding.target_name).left(1)))
				#"popb":
					#parent.set(binding.target_name, parent.get(binding.target_name).rstrip(parent.get(binding.target_name).reft(1)))
		#
		#if binding.has("callable"):
			#parent.call(binding.callable.name)
		

func is_binding_triggered(binding : ActionPropertyBinding) -> bool:
	var result : int = 1
	
	for key in binding.keys:
		if !Input.is_key_pressed(key):
			result = 0
		
	for mouse_button in binding.mouse_buttons:
		if (mouse_button == MOUSE_BUTTON_WHEEL_UP or mouse_button == MOUSE_BUTTON_WHEEL_DOWN) and _mouse_scroll_buffer.has(mouse_button) and result != 0:
			result = _mouse_scroll_buffer.count(mouse_button)
		elif mouse_button != MOUSE_BUTTON_WHEEL_UP and mouse_button != MOUSE_BUTTON_WHEEL_DOWN and result != 0 and Input.is_mouse_button_pressed(mouse_button):
			result = 1
		else:
			result = 0
		#print("i am ", mouse_button, " and triggered = ", result)
		_mouse_scroll_buffer.erase(mouse_button)
	
	return result
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		_mouse_scroll_buffer.append(event.button_index)
		#print("set scroll buffer to ", mouse_scroll_buffer)
