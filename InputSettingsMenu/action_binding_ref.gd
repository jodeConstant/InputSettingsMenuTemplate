extends Label

class_name ActionBindingRef

@export var action_name: StringName

@export var kb_binding_buttons: Array[InputSettingsButton]
@export var ms_binding_buttons: Array[InputSettingsButton]
@export var ct_binding_buttons: Array[InputSettingsButton]


func _ready():
	var index: = 0
	for b in kb_binding_buttons:
		b.action_name = action_name
		b.input_set_preliminary.connect(check_overlap)
		b.index = index
		index += 1
#		print_debug("%s set action_name of %s to %s" %[self.name, b.name, action_name])
	for b in ms_binding_buttons:
		b.action_name = action_name
		b.input_set_preliminary.connect(check_overlap)
		b.index = index
		index += 1
#		print_debug("%s set action_name of %s to %s" %[self.name, b.name, action_name])
	for b in ct_binding_buttons:
		b.action_name = action_name
		b.input_set_preliminary.connect(check_overlap)
		b.index = index
		index += 1
#		print_debug("%s set action_name of %s to %s" %[self.name, b.name, action_name])

func check_overlap(button: InputSettingsButton):
	print_debug("Preliminary overlap check")
	var button_array: Array[InputSettingsButton]
	if button is InputSettingsButtonKb:
		button_array = kb_binding_buttons
	elif button is InputSettingsButtonMs:
		button_array = ms_binding_buttons
	else:
		button_array = ct_binding_buttons
	for b in button_array:
		if (b != button) and (b.curr_input_code == button.curr_input_code):
			b.reset_binding(true, false)
