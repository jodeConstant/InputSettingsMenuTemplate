extends Node

class_name InputMapConfig

var config_file_path: = "res://InputSettingsTests/InputMapPref.ini"

# Add configurable actions in InputMap to this array
# OR leave empty to automatically add all non- built-in actions
var configurable_actions: Array[StringName] \
	= [
		
	]

@onready var config_file: = ConfigFile.new()

# 3 keys, mouse + key combinations and controller buttons
var MAX_PER_TYPE: int = 3

func configure():
	if not config_file:
		config_file = ConfigFile.new()
		
	if configurable_actions.is_empty():
		configurable_actions = InputMap.get_actions().slice(76)
	
	if config_file.load(config_file_path) == OK:
		_load_inputs()
	else:# defaults
		_save_default_inputmap()


func _save_default_inputmap():
	print_debug("Saving InputMap to file...")
	print_debug("TESTING: Printing InputMap to console...")
	var _actions: = InputMap.get_actions().slice(76)
	var _events: Array[InputEvent]
	var _e: InputEvent
	var input_indices: Vector3i# x = key, y = mouse, z = controller / "joypad"
	for a in _actions:
		print_debug("Saving action \"%s\" to config file:" % a)
		input_indices = Vector3i.ZERO
		_events = InputMap.action_get_events(a)
		for ev in _events:
			if ev is InputEventKey and input_indices.x < MAX_PER_TYPE:
				_e = ev as InputEventKey
				config_file.set_value(
					a, 
					str(10 + input_indices.x), 
					_e.get_physical_keycode_with_modifiers()
					)
				input_indices.x += 1
				
			elif ev is InputEventMouseButton and input_indices.y < MAX_PER_TYPE:
				_e = ev as InputEventMouseButton
				config_file.set_value(
					a, 
					str(20 + input_indices.y), 
					_e.button_index | _e.get_modifiers_mask()
					)
				input_indices.y += 1
				
			elif ev is InputEventJoypadButton and input_indices.z < MAX_PER_TYPE:
				_e = ev as InputEventJoypadButton
				config_file.set_value(
					a, 
					str(30 + input_indices.z), 
					_e.button_index
					)
				input_indices.z += 1
			print_debug(ev)
		print_debug("---------")
	config_file.save(config_file_path)

func _load_inputs():
	var keys: PackedStringArray
	var read_val
	for a in config_file.get_sections():
		if not InputMap.has_action(a):
			# not a valid setting, continue to next section / action
			continue
			
		# no keys = no mapped inputs / input bindings
		InputMap.action_erase_events(a)
		keys = config_file.get_section_keys(a)
		if keys.is_empty():
			continue
			
		keys.sort()
		for k in keys:
			read_val = config_file.get_value(a, k)
			if read_val is int:
				_add_event_to_map(
					a, 
					int(k) / 10, 
					int(read_val)
					)
		print_debug("---------")

func _add_event_to_map(action: StringName, type: int, code: int):
	if type == 3:
		var joy_ev: = InputEventJoypadButton.new()
		joy_ev.button_index = code as JoyButton
		InputMap.action_add_event(action, joy_ev)
		print_debug(joy_ev)
	else:
		var modd_ev: InputEventWithModifiers
		if type == 1:
			modd_ev = InputEventKey.new()
			modd_ev.physical_keycode = code & KEY_CODE_MASK
		else:# 2
			modd_ev = InputEventMouseButton.new()
			modd_ev.button_index = code
		
		modd_ev.ctrl_pressed = code & KEY_MASK_CTRL
		modd_ev.shift_pressed = code & KEY_MASK_SHIFT
		modd_ev.alt_pressed = code & KEY_MASK_ALT
		modd_ev.meta_pressed = code & KEY_MASK_META
		InputMap.action_add_event(action, modd_ev)
		print_debug(modd_ev)

func _ready():
	configure()