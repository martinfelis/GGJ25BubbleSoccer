extends Panel

@onready var menu_state_machine: MenuStateMachine = %MenuStateMachine
@onready var resume_button: Button = $CenterContainer/VBoxContainer/VBoxContainer/ResumeButton
@onready var game: Game = %Game

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()		
		menu_state_machine.switch_to_state(menu_state_machine.game_ui_state)

func _on_visibility_changed() -> void:
	if not is_instance_valid(game):
		return
	
	if visible:
		game.process_mode = Node.PROCESS_MODE_DISABLED
		resume_button.grab_focus()
	else:
		game.process_mode = Node.PROCESS_MODE_INHERIT

func _on_resume_button_pressed() -> void:
	menu_state_machine.switch_to_state(menu_state_machine.game_ui_state)

func _on_end_game_pressed() -> void:
	menu_state_machine.switch_to_state(menu_state_machine.main_menu_state)
