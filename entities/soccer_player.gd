@tool
class_name SoccerPlayer
extends RigidBody3D

# signals

# enums
enum TeamName {RED, BLUE}
@export var team_name: TeamName :
	set(value):
		team_name = value
		update_team()
	get:
		return team_name

# constants
const SPEED:float = 20.0
const SPEED_WITH_BALL:float = 10.0
const ACCEL:float = 34.0
const SHOOT_SPEED:float = 10.0
const JUMP_VELOCITY:float = 4.5
const BOUNCE_ACCEL_TIMEOUT:float = 1
const BLUE_MATERIAL:Material = preload("res://materials/team_blue_material.tres")
const RED_MATERIAL:Material = preload("res://materials/team_red_material.tres")
# const BLUE_PLAYER_MATERIAL:Material = preload("res://materials/team_blue_material.tres")
# const RED_PLAYER_MATERIAL:Material = preload("res://materials/team_red_player_material.tres")

# @export variables
@export var project_velocity_on_direction:bool = true
@export var is_player_controlled:bool :
	set(value):
		is_player_controlled = value
		
		if is_instance_valid(bt_player):
			bt_player.active = not is_player_controlled

		if not is_player_controlled:
			add_to_group("NPCPlayer")
	get:
		return is_player_controlled

# public variables
@onready var geometry: Node3D = %Geometry
@onready var bt_player: BTPlayer = %BTPlayer
@onready var bubble_body: MeshInstance3D = %BubbleBody
@onready var hair: MeshInstance3D = %Hair

var steering_target:Vector3 = Vector3.ZERO
var do_shoot:bool = false
var is_steering_active:bool = false
var connected_ball:Ball = null

# private variables
var _look_angle:float = 0
var _last_look_angle:float = 0
var _look_angle_spring = SpringDamper.new(0, 4, 0.06, 0.03)
var _is_on_floor:bool = false

var _planar_steering_direction:Vector3 = Vector3.BACK * 0.01

func _ready() -> void:
	_look_angle = -global_transform.basis.z.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	
	update_team()
	
	if not is_player_controlled:
		bt_player.active = true
		add_to_group("NPCPlayer")
	else:
		bt_player.active = false

func update_team():
	if not is_instance_valid(bubble_body) or not is_instance_valid(hair):
		return
		
	if team_name == TeamName.RED:
		bubble_body.set_surface_override_material(0, RED_MATERIAL)
		hair.set_surface_override_material(0, RED_MATERIAL)
	else:
		bubble_body.set_surface_override_material(0, BLUE_MATERIAL)
		hair.set_surface_override_material(0, BLUE_MATERIAL)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_is_on_floor = false
	
	var planar_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
	
	var debug_draw_contact_points:PackedVector3Array = PackedVector3Array()
	var debug_draw_contact_normals:PackedVector3Array = PackedVector3Array()
	debug_draw_contact_points.resize(state.get_contact_count())
	debug_draw_contact_normals.resize(state.get_contact_count())
	
	for i in range(state.get_contact_count()):
		debug_draw_contact_points[i] = state.get_contact_collider_position(i)
		debug_draw_contact_normals[i] = state.get_contact_local_normal(i)
		var normal:Vector3 = global_basis.transposed() * state.get_contact_local_normal(i)
		if normal.y > 0.9:
			_is_on_floor = true
			continue
	
	DebugDraw3D.draw_points(debug_draw_contact_points)
	
	var planar_speed:float = 0
	if planar_velocity:
		planar_speed = planar_velocity.length()

	var steering_tangential:Vector3 = _planar_steering_direction
	var steering_orthogonal:Vector3 = Vector3.ZERO
	if _planar_steering_direction and planar_velocity:
			steering_tangential = _planar_steering_direction.dot(planar_velocity) * planar_velocity.normalized()
			steering_orthogonal = _planar_steering_direction - steering_tangential
	
	var max_speed = SPEED
	if connected_ball:
		max_speed = SPEED_WITH_BALL
	
	if planar_speed < max_speed or steering_tangential.dot(planar_velocity) <= 0:
		state.apply_central_force(_planar_steering_direction * ACCEL)
	else:
		state.apply_central_force(steering_orthogonal * ACCEL)

func _handle_player_controls() -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_planar_steering_direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if Input.is_action_just_pressed("shoot"):
		do_shoot = true

func update_look_direction(delta:float) -> void:
	var planar_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
	
	var current_look_angle = _look_angle
	var target_look_angle = _last_look_angle
	
	if planar_velocity.length() > 0.1:
		target_look_angle = -planar_velocity.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	elif _planar_steering_direction:
		target_look_angle = -_planar_steering_direction.signed_angle_to(Vector3.FORWARD, Vector3.UP)

	assert(is_finite(target_look_angle))

	if target_look_angle - current_look_angle > PI:
		current_look_angle = current_look_angle + 2 * PI
	elif current_look_angle - target_look_angle > PI:
		current_look_angle = current_look_angle - 2 * PI

	_look_angle = _look_angle_spring.calc(current_look_angle, target_look_angle, delta)
	_last_look_angle = _look_angle

func update_steering() -> void:
	if is_player_controlled:
		_handle_player_controls()
	elif is_steering_active:
		_planar_steering_direction = Vector3(steering_target.x - global_position.x, 0, steering_target.z - global_position.z)
		if _planar_steering_direction:
			_planar_steering_direction = _planar_steering_direction.normalized()
	else:
		_planar_steering_direction = Vector3.ZERO

func _physics_process(delta: float) -> void:
	update_steering()

	update_look_direction(delta)

	if do_shoot and connected_ball:
		if team_name == TeamName.BLUE:
			connected_ball.ignore_timer_blue = 1
		else:
			connected_ball.ignore_timer_red = 1
			
		connected_ball.linear_velocity = linear_velocity - global_basis.z * SHOOT_SPEED
		connected_ball.connected_player = null
		connected_ball = null
	else:
		do_shoot = false
	
	DebugDraw3D.draw_arrow(global_position + Vector3.UP * 0.1, global_position + _planar_steering_direction * 5  + Vector3.UP * 0.1, Color.RED, 0.4, true)
	
	basis = Basis.from_euler(Vector3(0, _look_angle, 0))
	
	if connected_ball:
		connected_ball.global_position = global_position - global_basis.z * 1.3 + Vector3.UP * 0.3

func _on_body_entered(body: Node) -> void:
	var other_soccer_player:SoccerPlayer = body as SoccerPlayer
	if not other_soccer_player:
		return

func _on_ball_detection_area_body_entered(body: Node3D) -> void:
		var ball:Ball = body as Ball
		
		if ball and connected_ball == null:
			connected_ball = ball
			connected_ball.connected_player = self
