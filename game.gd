class_name Game
extends Node3D

signal score_updated()

@export var reset_balls:bool = true

@onready var camera_3d: Camera3D = %Camera3D

var _camera_offset:Vector3 = Vector3.UP * 10 + Vector3.BACK * 5# + Vector3.RIGHT * 10
var _camera_center:Vector3 = Vector3.ZERO

var blue_score:int = 0
var red_score:int = 0

func _ready() -> void:
	_camera_offset = camera_3d.global_position

	for ball:Ball in get_tree().get_nodes_in_group("Ball"):
		ball.connect("ball_reset", on_ball_reset)
		
	for goal:Goal in get_tree().get_nodes_in_group("Goal"):
		goal.connect("ball_detected", on_goal_ball_detected)

func reset_game():
	blue_score = 0
	red_score = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for soccer_player:SoccerPlayer in get_tree().get_nodes_in_group("SoccerPlayer"):
		# TODO: extend for multiple player controlled soccer players
		if soccer_player.is_player_controlled:
			_camera_center = soccer_player.global_position
	
	camera_3d.global_position = _camera_center + _camera_offset
	camera_3d.look_at(_camera_center)
	
func on_ball_reset(ball:Ball) -> void:
	ball.global_position = Vector3(randf() -0.5, 0.5, randf() - 0.5)
	ball.linear_velocity = Vector3(randf() -0.5, 2, randf() - 0.5) * 5

func on_goal_ball_detected(goal:Goal, ball:Ball):
	if goal.team_name == goal.TeamName.RED:
		red_score += 1
	else:
		blue_score += 1
	
	score_updated.emit()
	
	on_ball_reset(ball)

func _on_game_field_area_body_entered(body: Node3D) -> void:
	var ball:Ball = body as Ball
	
	if not ball:
		return
	
	ball.on_enter_game_area()

func _on_game_field_area_body_exited(body: Node3D) -> void:
	if not reset_balls:
		return
		
	var ball:Ball = body as Ball
	
	if not ball:
		return

	ball.on_leave_game_area()
