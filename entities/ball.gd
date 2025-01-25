class_name Ball
extends RigidBody3D

const BALL_RESET_TIME = 3

var _reset_time:float = 0

signal ball_reset(ball)

func _process(delta: float) -> void:
	if _reset_time > 0:
		_reset_time -= delta
		
	if _reset_time < 0:
		_reset_time = 0
		ball_reset.emit(self)

func on_leave_game_area() -> void:
	_reset_time = BALL_RESET_TIME

func on_enter_game_area() -> void:
	_reset_time = 0
