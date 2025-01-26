class_name MenuStateMachine
extends Node

@onready var main_menu_state: MenuState = %MainMenuState
@onready var game_ui_state: MenuState = %GameUIState
@onready var pause_ui_state: MenuState = %PauseUIState

var current_state:MenuState = null
@onready var next_state:MenuState = main_menu_state

@onready var available_states = [main_menu_state, game_ui_state, pause_ui_state]

func _ready():
	for state:MenuState in available_states:
		state.leave()

func switch_to_state(state:MenuState):
	print ("Setting next state to %s" % state.name)
	next_state = state

func _process(_delta: float) -> void:
	if not is_instance_valid(next_state):
		return
	
	if next_state != current_state and is_instance_valid(current_state):
		current_state.leave()
	
	current_state = next_state
	next_state = null

	current_state.enter()
