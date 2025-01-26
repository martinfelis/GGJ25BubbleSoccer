extends Panel

@onready var menu_state_machine: MenuStateMachine = %MenuStateMachine

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		menu_state_machine.switch_to_state(menu_state_machine.pause_ui_state)


func _on_main_menu_ui_visibility_changed() -> void:
	pass # Replace with function body.
