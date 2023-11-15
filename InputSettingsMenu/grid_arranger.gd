@tool
extends Control

@export var organize_buttons: bool:
	set(value):
		if Engine.is_editor_hint():
			arrange_buttons()

# uses LOCAL positions
@export var first_label_position: Vector2
@export var first_button_position: Vector2
@export var label_spacing: float
@export var button_spacing: Vector2

@export var action_label_container: Node

func arrange_buttons():
	var action_labels: Array[Node] = action_label_container.get_children()
	print_debug(action_labels)
	var label_as_ref: ActionBindingRef
	var label_position: Vector2 = first_label_position
	var button_position: Vector2 = first_button_position
	var button_count: int
	for label in action_labels:
		label_as_ref = label as ActionBindingRef
		label_as_ref.position = label_position
		button_count = max(
			label_as_ref.kb_binding_buttons.size(),
			label_as_ref.ms_binding_buttons.size(),
			label_as_ref.ct_binding_buttons.size()
			)
		for i in range(button_count):
			if i < label_as_ref.kb_binding_buttons.size():
				label_as_ref.kb_binding_buttons[i].position = button_position
			if i < label_as_ref.ms_binding_buttons.size():
				label_as_ref.ms_binding_buttons[i].position = button_position
			if i < label_as_ref.ct_binding_buttons.size():
				label_as_ref.ct_binding_buttons[i].position = button_position
			button_position.x += button_spacing.x
		
		label_position.y += label_spacing
		button_position.y += button_spacing.y
		button_position.x = first_button_position.x
