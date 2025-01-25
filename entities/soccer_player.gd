@tool
class_name SoccerPlayer
extends RigidBody3D

# signals

# enums
enum TeamName {RED, BLUE}
@export var team_name: TeamName :
	set(value):
		team_name = value
		set_team(team_name)
	get:
		return team_name

# constants
const SPEED:float = 20.0
const ACCEL:float = 34.0
const JUMP_VELOCITY:float = 4.5
const BOUNCE_ACCEL_TIMEOUT:float = 1
const BLUE_MATERIAL:Material = preload("res://materials/team_blue_material.tres")
const RED_MATERIAL:Material = preload("res://materials/team_red_material.tres")

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
var is_steering_active:bool = false

# private variables
var _look_angle:float = 0
var _last_look_angle:float = 0
var _planar_steering_direction:Vector3 = Vector3.BACK * 0.01
var _look_angle_spring = SpringDamper.new(0, 4, 0.06, 0.03)
var _is_on_floor:bool = false

func _ready() -> void:
	_look_angle = -global_transform.basis.z.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	
	set_team(team_name)
	
	if not is_player_controlled:
		bt_player.active = true
		add_to_group("NPCPlayer")

func set_team(team:TeamName):
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
	
	if planar_speed < SPEED or steering_tangential.dot(planar_velocity) <= 0:
		state.apply_central_force(_planar_steering_direction * ACCEL)
	else:
		state.apply_central_force(steering_orthogonal * ACCEL)

func _handle_player_controls() -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_planar_steering_direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

func update_look_direction(delta:float) -> void:
	var planar_velocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
	
	var current_look_angle = _look_angle
	var target_look_angle = _last_look_angle
	
	if planar_velocity.length() > 0.1:
		target_look_angle = -planar_velocity.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	elif _planar_steering_direction:
		target_look_angle = -_planar_steering_direction.signed_angle_to(Vector3.FORWARD, Vector3.UP)

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
	DebugDraw2D.set_text(name + ".is_steering_active", str(is_steering_active))
	DebugDraw2D.set_text(name + "._is_on_floor", str(_is_on_floor))

	update_steering()

	update_look_direction(delta)
	
	DebugDraw3D.draw_arrow(global_position + Vector3.UP * 0.1, global_position + _planar_steering_direction * 5  + Vector3.UP * 0.1, Color.RED, 0.4, true)
	
	basis = Basis.from_euler(Vector3(0, _look_angle, 0))

func _on_body_entered(body: Node) -> void:
	var other_soccer_player:SoccerPlayer = body as SoccerPlayer
	if not other_soccer_player:
		return
	
	#if other_soccer_player and _bounce_timeout == 0 and is_player_controlled:
		#var relative_velocity:Vector3 = other_soccer_player.linear_velocity - linear_velocity
		#var vector_to_body:Vector3 = other_soccer_player.global_position - global_position
		#var direction_to_body = vector_to_body.normalized()
		#_bounce_timeout = BOUNCE_ACCEL_TIMEOUT
		#_velocity = linear_velocity
		#other_soccer_player._velocity = other_soccer_player.linear_velocity
		
		#if relative_velocity.dot(direction_to_body) > 0:
			#vector_to_body.y = 0
#			other_soccer_player.apply_impulse((vector_to_body).normalized() * 2)

			#_velocity = Vector3.ZERO
			
