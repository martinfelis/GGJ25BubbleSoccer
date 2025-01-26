extends Panel

@onready var game: Game = %Game
@onready var team_size_label: Label = %TeamSizeLabel
@onready var team_size_slider: HSlider = %TeamSizeSlider
@onready var main_menu_ui: Panel = %MainMenuUI
@onready var menu_state_machine: MenuStateMachine = %MenuStateMachine
@onready var game_options: VBoxContainer = %GameOptions
@onready var start_button: Button = %StartButton

func _ready() -> void:
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_team_size_slider_value_changed(value: float) -> void:
	team_size_label.text = str(value)

func _on_start_button_pressed() -> void:
	game.team_size = int(team_size_slider.value)
	game.start_game()
	menu_state_machine.switch_to_state(menu_state_machine.game_ui_state)

func _on_visibility_changed() -> void:
	if is_instance_valid(start_button) and visible:
		game.start_demo_game()
		start_button.grab_focus()
