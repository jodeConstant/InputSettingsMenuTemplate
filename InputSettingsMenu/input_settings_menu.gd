extends Control

@export var all_tabs: Array[Control]
@export var current_tab: Control

var all_kb_buttons: Array[InputSettingsButton]
var all_ms_buttons: Array[InputSettingsButton]
var all_ct_buttons: Array[InputSettingsButton]

# Assign parent node of ActionBindingRef nodes:
@export var action_refs_container: Node
var action_refs_list: Array[ActionBindingRef]
var ref_action: StringName

@export var save_to_file_on_close: bool = true

func _exit_tree():
	if save_to_file_on_close:
		CustomInputConfig.save_settings()

func _ready():
	# Set up tabs:
	for p in all_tabs:
		p.visible = false
		
	if current_tab and all_tabs.has(current_tab):
		current_tab.visible = true
	else:
		current_tab = all_tabs[0]
		current_tab.visible = true
	
	# Sets up action bundle references:
	action_refs_list.assign(
		action_refs_container.get_children()
		)
	
	# Assigns button reference arrays
	for ref in action_refs_list:
		all_kb_buttons.append_array(ref.kb_binding_buttons)
		all_ms_buttons.append_array(ref.ms_binding_buttons)
		all_ct_buttons.append_array(ref.ct_binding_buttons)
	
	# Connecting signals here, there would be a lot to do manually
	for kb_button in all_kb_buttons:
		kb_button.input_set.connect(_check_input_conflicts)
	for ms_button in all_ms_buttons:
		ms_button.input_set.connect(_check_input_conflicts)
	for ct_button in all_ct_buttons:
		ct_button.input_set.connect(_check_input_conflicts)
	
	set_up_button_data()

# Sets up buttons' input code variables and calls update text functions
func set_up_button_data():
	print_debug("Setting up menu button data")
	var read_value
	for ref in action_refs_list:
		ref_action = ref.action_name
		
		for kb_button in ref.kb_binding_buttons:
			read_value = CustomInputConfig.config_file.get_value(
				ref_action, 
				str(10 + kb_button.index), 
				-1)
			kb_button.curr_input_code = read_value if (read_value is int) else -1
			kb_button.update_button_text()
			print_debug("Set button %s code to %d" % [kb_button.name, read_value])
		
		for ms_button in ref.ms_binding_buttons:
			read_value = CustomInputConfig.config_file.get_value(
				ref_action, 
				str(20 + ms_button.index), 
				-1)
			ms_button.curr_input_code = read_value if (read_value is int) else -1
			ms_button.update_button_text()
			print_debug("Set button %s code to %d" % [ms_button.name, read_value])
		
		for ct_button in ref.ct_binding_buttons:
			read_value = CustomInputConfig.config_file.get_value(
				ref_action, 
				str(30 + ct_button.index), 
				-1)
			ct_button.curr_input_code = read_value if (read_value is int) else -1
			ct_button.update_button_text()
			print_debug("Set button %s code to %d" % [ct_button.name, read_value])
	print_debug("---------")

# Not sure how to avoid missing potential overlaps for sure,
# without allocating noticeable amounts of memory for additional
# arrays in some cases, so checking all buttons of type each time
# 	TODO: Add a notification if the button that triggers this is
# 	conflicting after the new input is assigned = is now / still
# 	in conflict with some other button.
func _check_input_conflicts(button: InputSettingsButton):
	print_debug("Conflict check")
	var type: int
	var button_array: Array[InputSettingsButton]
	if button is InputSettingsButtonKb:
		type = 1
		button_array = all_kb_buttons
	elif button is InputSettingsButtonMs:
		type = 2
		button_array = all_ms_buttons
	else:
		type = 3
		button_array = all_ct_buttons
	print_debug(
		"Checking input conflicts of type %d" % type
		)
	
	for b in button_array:
		b.conflict = false
	
	for x in range(button_array.size() - 1):
		if button_array[x].curr_input_code < 0:
			button_array[x].conflict = false
			#print_debug("%s cannot conflict" % button_array[x])
			continue
			
		for y in range(x + 1, button_array.size()):
			if button_array[y].curr_input_code < 0:
				button_array[y].conflict = false
				#print_debug("%s cannot conflict" % button_array[y])
				continue
			# ELSE:
			if button_array[x].curr_input_code \
			== button_array[y].curr_input_code:
				button_array[x].conflict = true
				button_array[y].conflict = true

# Connect tab changing button signals to this
func _on_tab_changed(tab: int):
	if tab <= all_tabs.size():
		if all_tabs[tab] != current_tab:
			current_tab.visible = false
			current_tab = all_tabs[tab]
			current_tab.visible = true

# Connect restoring defaults confirmation prompt to this,
# not yet implemented here
func _show_restore_defaults_confirm():
	pass

# Restore defaults, ideally connect an "Ok" / "Yes"
# button in cofirmation prompt / pop-up to this
func _restore_defaults():
	CustomInputConfig.restore_defaults()
	set_up_button_data()
