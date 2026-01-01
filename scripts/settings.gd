extends Control

func open_settings_page() -> void:
	visible = true
	var _values : Dictionary[String, Array] = ConfigurableValues.get_configurable_values()
	
	for _value_cat : String in _values:
		var _label : Label = Label.new()
		_label.text = _value_cat
		$settings.add_child(HSeparator.new())
		$settings.add_child(_label)
		
		for _prop : Dictionary in _values[_value_cat]:
			var _property_box : HBoxContainer = $settings/empty_property.duplicate()
			_property_box.visible = true
			_property_box.get_node("property_name").text = _prop.name.replace("_", " ").capitalize()
			$settings.add_child(_property_box)
			
			var _property_editor
			
			if _prop.type == TYPE_BOOL:
				_property_editor = CheckButton.new()
				_property_editor.button_pressed = ConfigurableValues.get(_prop.name)
				_property_editor.toggled.connect(func(x): ConfigurableValues.set(_prop.name, x))
			elif _prop.type == TYPE_FLOAT:
				if _prop.hint == 1:
					var _hints : Array = Array(_prop.hint_string.split(","))
					_property_editor = HSlider.new()
					_property_editor.min_value = float(_hints[0])
					_property_editor.max_value = float(_hints[1])
					_property_editor.step = float(_hints[2])
					_property_editor.value = ConfigurableValues.get(_prop.name)
					_property_editor.value_changed.connect(func(x): ConfigurableValues.set(_prop.name, x))
					
					
			_property_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_property_box.add_child(_property_editor)

func close_settings_panel() -> void:
	visible = false
