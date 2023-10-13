extends Button

class_name InputSettingsButton

var action_name: StringName
var new_input_code: int
var curr_input_code: int

var index: int

var conflict: bool:
	get:
		return conflict
	set(value):
		if conflict != value:
			conflict = value
			add_theme_color_override(
				font_color, 
				Color.RED if conflict else Color.WHITE
				)

var font_color: StringName = "font_color"

signal input_set_preliminary(button)
signal input_set(button)

func update_button_text():
	pass

func reset_binding(update_text: bool = true, removing_duplicate: bool = false):
	pass
