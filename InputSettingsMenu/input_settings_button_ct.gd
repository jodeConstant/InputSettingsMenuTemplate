extends InputSettingsButton

class_name InputSettingsButtonCt

var ct_event: InputEventJoypadButton

func update_button_text():
	text = ("Button %d" % curr_input_code) \
				if curr_input_code > -1 else ""

func reset_binding(update_text: bool = true):
	if ct_event:
		InputMap.action_erase_event(action_name, ct_event)
	else:
		ct_event = InputEventJoypadButton.new()
		ct_event.button_index = curr_input_code as JoyButton
		InputMap.action_erase_event(action_name, ct_event)
	
	curr_input_code = -1
	if update_text:
		update_button_text()
	
	ct_event = null

func _gui_input(event):
	if event is InputEventJoypadButton:
		if event.pressed:
			if event.button_index != curr_input_code:
				if (curr_input_code > -1) or ct_event:
					reset_binding(false)
					
				new_input_code = event.button_index
				
				ct_event = InputEventJoypadButton.new()
				ct_event.button_index = new_input_code
				
				InputMap.action_add_event(action_name, ct_event)
				
				CustomInputConfig.config_file.set_value(
					action_name, 
					str(30 + index), 
					new_input_code
					)
		
				print_debug("new event:")
				print_debug(ct_event)
				
				curr_input_code = new_input_code
				
				input_set.emit(self)
				
				update_button_text()
			
			accept_event()
			release_focus()
	
	elif event is InputEventKey:
		if event.physical_keycode == KEY_ESCAPE:
			release_focus()
			accept_event()
