class_name Ball
extends RigidBody3D

const BALL_RESET_TIME = 3

var connected_player:SoccerPlayer = null
var _reset_time:float = 0
var ignore_timer_blue:float = 3
var ignore_timer_red:float = 3

signal ball_reset(ball)

func _process(delta: float) -> void:
	_process_reset(delta)
	
	ignore_timer_blue = move_toward(ignore_timer_blue, 0, delta)
	ignore_timer_red = move_toward(ignore_timer_red, 0, delta)
	
func _process_reset(delta:float) -> void:
	if _reset_time > 0:
		_reset_time -= delta
		
	if _reset_time < 0:
		_reset_time = 0
		
		ball_reset.emit(self)	

func reset_ball():
	ignore_timer_blue = 0
	ignore_timer_red = 0

	reset_player_connection()	

func reset_player_connection():
	if connected_player:
		connected_player.connected_ball = null
	connected_player = null
	

func is_owned_by_team(team_name:SoccerPlayer.TeamName) -> bool:
	if connected_player == null:
		return false
	
	if connected_player and is_instance_valid(connected_player):
		return team_name == connected_player.team_name
	
	reset_player_connection()
	return false

func on_leave_game_area() -> void:
	_reset_time = BALL_RESET_TIME

func on_enter_game_area() -> void:
	_reset_time = 0
