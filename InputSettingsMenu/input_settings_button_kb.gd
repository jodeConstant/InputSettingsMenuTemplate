extends InputSettingsButton

class_name InputSettingsButtonKb

@onready var lbl_ctrl: Label = $Ctrl
@onready var lbl_meta: Label = $Meta
@onready var lbl_alt: Label = $Alt
@onready var lbl_shift: Label = $Shift

var kb_event: InputEventKey

# bits greatest to least significant: meta, alt, shift, ctrl
var _key_bits: int
var _mod_bits: int
var key_label: int = 0

func  _ready():
	lbl_meta.text = "+" + OS.get_keycode_string(KEY_META)

func update_button_text():
	if curr_input_code > 0:
		text = OS.get_keycode_string((curr_input_code & KEY_CODE_MASK) as Key)
		
		lbl_ctrl.visible = bool(curr_input_code & KEY_MASK_CTRL)
		lbl_meta.visible = bool(curr_input_code & KEY_MASK_META)
		lbl_alt.visible = bool(curr_input_code & KEY_MASK_ALT)
		lbl_shift.visible = bool(curr_input_code & KEY_MASK_SHIFT)
	else:
		text = ""

func reset_binding(update_text: bool = true):
	if kb_event:
		InputMap.action_erase_event(action_name, kb_event)
	
	else:
		kb_event = InputEventKey.new()
		
		kb_event.physical_keycode = (curr_input_code & KEY_CODE_MASK) as Key
		
		kb_event.meta_pressed = curr_input_code & KEY_MASK_META
		kb_event.alt_pressed = curr_input_code & KEY_MASK_ALT
		kb_event.shift_pressed = curr_input_code & KEY_MASK_SHIFT
		kb_event.ctrl_pressed = curr_input_code & KEY_MASK_CTRL
	
	curr_input_code = -1
	if update_text:
		update_button_text()
	
	kb_event = null

# finalize setting
func _set_binding():
	print_debug("assigning a new binding")
	
	if curr_input_code == new_input_code:
		print_debug(
			"Attempted assigning same input, code: %d" % new_input_code
			)
		return
	
	# generate InputEventKey
	if (curr_input_code > 0) or kb_event:
		reset_binding(false)
		print_debug("binding reset")
	
	kb_event = InputEventKey.new()
	
	kb_event.physical_keycode = (new_input_code & KEY_CODE_MASK) as Key
	
	kb_event.meta_pressed = new_input_code & KEY_MASK_META
	kb_event.alt_pressed = new_input_code & KEY_MASK_ALT
	kb_event.shift_pressed = new_input_code & KEY_MASK_SHIFT
	kb_event.ctrl_pressed = new_input_code & KEY_MASK_CTRL
	
	InputMap.action_add_event(action_name, kb_event)
	
	CustomInputConfig.config_file.set_value(
				action_name, 
				str(10 + index), 
				new_input_code
				)
	
	print_debug("new event: %s" % kb_event)
	
	curr_input_code = new_input_code
	
	input_set.emit(self)
	
	update_button_text()

func _gui_input(event):
	if event is InputEventKey:
		print_debug("Raw input read is: %s" % event)
		if event.physical_keycode != KEY_ESCAPE:
			if event.pressed:
				key_label = event.key_label
				
				new_input_code = event.get_physical_keycode_with_modifiers()
				_key_bits = new_input_code & KEY_CODE_MASK
					
				print_debug("read event key is: %s" % _key_bits)
				print_debug("read event code: %d" % new_input_code)
				
				if (_key_bits != KEY_CTRL) and (_key_bits != KEY_SHIFT) \
				and (_key_bits != KEY_ALT) and (_key_bits != KEY_META):
					release_focus()
					_set_binding()
				accept_event()
				
			else:# released; no non-mod key was pressed
				# If key is Ctrl, no need to modify code modifier and key parts
				print_debug("on-release code starts as: %d" % new_input_code)
				if (new_input_code & KEY_CODE_MASK) != KEY_CTRL:
					# identify and remove primary key bits
					# set equivalent modifier bit
					if (new_input_code & KEY_CODE_MASK) == KEY_META:
						new_input_code = new_input_code | KEY_MASK_META
					elif (new_input_code & KEY_CODE_MASK) == KEY_ALT:
						new_input_code = new_input_code | KEY_MASK_ALT
					elif (new_input_code & KEY_CODE_MASK) == KEY_SHIFT:
						new_input_code = new_input_code | KEY_MASK_SHIFT
					# just clear all key bits
					new_input_code = new_input_code & KEY_MODIFIER_MASK
					
					print_debug("on-release code after adjusting modifiers is: %d" % new_input_code)
					
					if new_input_code & KEY_MASK_CTRL:
						new_input_code = new_input_code & (~KEY_MASK_CTRL)
						new_input_code = new_input_code | KEY_CTRL
						
					elif new_input_code & KEY_MASK_META:
						new_input_code = new_input_code & (~KEY_MASK_META)
						new_input_code = new_input_code | KEY_META
						
					elif new_input_code & KEY_MASK_ALT:
						new_input_code = new_input_code & (~KEY_MASK_ALT)
						new_input_code = new_input_code | KEY_ALT
						
					elif new_input_code & KEY_MASK_SHIFT:
						new_input_code = new_input_code & (~KEY_MASK_SHIFT)
						new_input_code = new_input_code | KEY_SHIFT
				
				key_label = new_input_code & KEY_CODE_MASK
				print_debug("on-release code ends up as: %d" % new_input_code)
				release_focus()
				accept_event()
				_set_binding()
		else:
			release_focus()
