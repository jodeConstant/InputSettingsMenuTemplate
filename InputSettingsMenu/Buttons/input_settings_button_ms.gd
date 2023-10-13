extends InputSettingsButton

class_name InputSettingsButtonMs

@onready var lbl_ctrl: Label = $Ctrl
@onready var lbl_meta: Label = $Meta
@onready var lbl_alt: Label = $Alt
@onready var lbl_shift: Label = $Shift

var ms_event: InputEventMouseButton

var reading: bool

func  _ready():
	lbl_meta.text = "+" + OS.get_keycode_string(KEY_META)

func update_button_text():
	if curr_input_code > 0:
		text = "Mouse %d" % (new_input_code & KEY_CODE_MASK)
		
		lbl_ctrl.visible = bool(curr_input_code & KEY_MASK_CTRL)
		lbl_meta.visible = bool(curr_input_code & KEY_MASK_META)
		lbl_alt.visible = bool(curr_input_code & KEY_MASK_ALT)
		lbl_shift.visible = bool(curr_input_code & KEY_MASK_SHIFT)
	else:
		text = ""

func reset_binding(update_text: bool = true, removing_duplicate: bool = false):
	if not removing_duplicate:
		if not ms_event:
			ms_event = InputEventMouseButton.new()
			
			ms_event.button_index = (curr_input_code & KEY_CODE_MASK) as MouseButton
			
			ms_event.meta_pressed = curr_input_code & KEY_MASK_META
			ms_event.alt_pressed = curr_input_code & KEY_MASK_ALT
			ms_event.shift_pressed = curr_input_code & KEY_MASK_SHIFT
			ms_event.ctrl_pressed = curr_input_code & KEY_MASK_CTRL
		
		InputMap.action_erase_event(action_name, ms_event)
	
	ms_event = null
		
	curr_input_code = -1
	
	CustomInputConfig.config_file.set_value(
					action_name, 
					str(20 + index), 
					curr_input_code
					)
					
	if update_text:
		update_button_text()

# finalize setting
func _set_binding():
	if curr_input_code == new_input_code:
		print_debug(
			"Attempted assigning same input, code: %d" % new_input_code
			)
		return
	
	# generate InputEventKey
	if (curr_input_code > 0) or ms_event:
		reset_binding(false)
	
	var _index = (new_input_code >> 25) - 1
	
	ms_event = InputEventMouseButton.new()
	
	ms_event.button_index = (new_input_code & KEY_CODE_MASK) as MouseButton
	
	ms_event.ctrl_pressed = new_input_code & KEY_MASK_CTRL
	ms_event.meta_pressed = new_input_code & KEY_MASK_META
	ms_event.alt_pressed = new_input_code & KEY_MASK_ALT
	ms_event.shift_pressed = new_input_code & KEY_MASK_SHIFT
	
	InputMap.action_add_event(action_name, ms_event)
	
	CustomInputConfig.config_file.set_value(
				action_name, 
				str(20 + index), 
				new_input_code
				)
	
	print_debug("new event:")
	print_debug(ms_event)
	
	curr_input_code = new_input_code
	
	input_set_preliminary.emit(self)
	input_set.emit(self)
	
	update_button_text()

func _gui_input(event):
	if event.is_pressed():
		if event is InputEventMouseButton:
			if reading:
				
				new_input_code = event.get_modifiers_mask() | event.button_index
				print_debug("mouse input code is: %d" % new_input_code)
				
				reading = false
				
				release_focus()
				_set_binding()
			elif event.button_index == MOUSE_BUTTON_LEFT:
				reading = true
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				reset_binding()
				input_set.emit(self)
			#accept_event()
		elif event is InputEventKey:
			if event.physical_keycode == KEY_ESCAPE:
				reading = false
				release_focus()
				#accept_event()
	accept_event()
