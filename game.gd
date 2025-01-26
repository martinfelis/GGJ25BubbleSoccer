class_name Game
extends Node3D

signal score_updated()

const STARTING_LINE_X_OFFSET:float = 15.0
const STARTING_LINE_LENGTH:float = 15.0
const SOCCER_PLAYER_SCENE = preload("res://entities/soccer_player.tscn")
const BALL_SCENE = preload("res://entities/ball.tscn")

@export var reset_balls:bool = true

@onready var camera_3d: Camera3D = %Camera3D
@onready var players: Node3D = %Players
@onready var balls: Node3D = %Balls

var _camera_offset:Vector3 = Vector3.UP * 10 + Vector3.BACK * 5# + Vector3.RIGHT * 10
var _camera_center:Vector3 = Vector3.ZERO

var blue_score:int = 0
var red_score:int = 0
var team_size:int = 1
var ball_count:int = 5
var player_count:int = 1

func _ready() -> void:
	_camera_offset = camera_3d.global_position

	for ball:Ball in get_tree().get_nodes_in_group("Ball"):
		ball.connect("ball_reset", on_ball_reset)
		
	for goal:Goal in get_tree().get_nodes_in_group("Goal"):
		goal.connect("ball_detected", on_goal_ball_detected)
	
func reset_game():
	blue_score = 0
	red_score = 0
	_camera_center = Vector3.ZERO
	
	for player:SoccerPlayer in players.get_children():
		player.get_parent().remove_child(player)
		player.queue_free()
	
	for ball:Ball in balls.get_children():
		ball.get_parent().remove_child(ball)
		ball.queue_free()

func spawn_players():
	var red_starting_line_origin = Vector3(-STARTING_LINE_X_OFFSET, 0, STARTING_LINE_LENGTH * 0.5)
	var blue_starting_line_origin = Vector3(STARTING_LINE_X_OFFSET, 0, STARTING_LINE_LENGTH * 0.5)
	
	var starting_line_offset = Vector3(0, 0, -STARTING_LINE_LENGTH / (team_size - 1))
	if team_size == 1:
		red_starting_line_origin.z = 0
		blue_starting_line_origin.z = 0
		starting_line_offset = Vector3.ZERO	
	
	for i in range(team_size):
		var red_player:SoccerPlayer = SOCCER_PLAYER_SCENE.instantiate()
		red_player.team_name = SoccerPlayer.TeamName.RED
		players.add_child(red_player)
		red_player.global_position = red_starting_line_origin + starting_line_offset * i + Vector3(randf() - 0.5, 0, randf() - 0.5) * 2

		var blue_player:SoccerPlayer = SOCCER_PLAYER_SCENE.instantiate()
		blue_player.team_name = SoccerPlayer.TeamName.BLUE
		players.add_child(blue_player)
		blue_player.global_position = blue_starting_line_origin + starting_line_offset * i  + Vector3(randf() - 0.5, 0, randf() - 0.5) * 2

func spawn_balls():
	for i in range(team_size):
		var ball:Ball = BALL_SCENE.instantiate()
		balls.add_child(ball)
		on_ball_reset(ball)

func assign_player_controls():
	var num_players_assigned:int = 0
	for player:SoccerPlayer in players.get_children():
		player.is_player_controlled = true
		num_players_assigned += 1
		
		if num_players_assigned == player_count:
			break

func start_demo_game():
	reset_game()
	spawn_balls()
	spawn_players()

func start_game():
	reset_game()
	spawn_balls()
	spawn_players()
	assign_player_controls()

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
	ball.linear_velocity = Vector3(randf() -0.5, 1, randf() - 0.5) * 8

	var connected_player = ball.connected_player

	if ball.connected_player:
		ball.connected_player = null
	
	if is_instance_valid(connected_player):
		connected_player.connected_ball = null

func on_goal_ball_detected(goal:Goal, ball:Ball):
	if goal.team_name == goal.TeamName.BLUE:
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
