class_name SoccerPlayer
extends RigidBody3D

# signals

# enums

# constants
const SPEED:float = 10.0
const ACCEL:float = 24.0
const JUMP_VELOCITY:float = 4.5
const BOUNCE_ACCEL_TIMEOUT:float = 1

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

var steering_target:Vector3 = Vector3.ZERO
var is_steering_active:bool = false
var steering_direction:Vector3 = Vector3.ZERO

# private variables
var _velocity:Vector3 = Vector3.ZERO
var _look_angle:float = 0
var _direction:Vector3 = Vector3.BACK
var _look_angle_spring = SpringDamper.new(0, 4, 0.06, 0.03)
var _is_on_floor:bool = false

func _ready() -> void:
	_look_angle = -global_transform.basis.z.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	bt_player.active = not is_player_controlled
	if bt_player.active:
		add_to_group("NPCPlayer")

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_is_on_floor = false
	
	var planar_velocity = Vector3(_velocity.x, 0, _velocity.z)
	var contact_projected_planar_velocity:Vector3 = planar_velocity
	
	for i in range(state.get_contact_count()):
		var normal:Vector3 = global_basis.transposed() * state.get_contact_local_normal(i)
		if normal.y > 0.9:
			_is_on_floor = true
			continue
		
		var contact_node:Node3D = state.get_contact_collider_object(i) as Node3D
		if not contact_node:
			continue

		if is_player_controlled:
			print (normal)

		if contact_projected_planar_velocity.length() < 0.01:
			contact_projected_planar_velocity = Vector3.ZERO
			break

		var velocity_projection:float = contact_projected_planar_velocity.dot(normal)
		if contact_node.is_in_group("Bound") and contact_projected_planar_velocity and velocity_projection < 0:
			contact_projected_planar_velocity -= velocity_projection * normal
	
	if is_player_controlled and contact_projected_planar_velocity != planar_velocity:
		print ("planar_vel_correction: %s" % (contact_projected_planar_velocity - planar_velocity))
	
	linear_velocity.x = contact_projected_planar_velocity.x
	linear_velocity.z = contact_projected_planar_velocity.z

func _handle_player_controls(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

func calc_desired_velocity(delta:float) -> void:
	var previous_speed:float = _velocity.length()
	
	if _direction and _is_on_floor:
		_velocity.x = _velocity.x + _direction.x * ACCEL * delta
		_velocity.z = _velocity.z + _direction.z * ACCEL * delta
	else:
		_velocity.x = move_toward(_velocity.x, 0, SPEED)
		_velocity.z = move_toward(_velocity.z, 0, SPEED)

	var current_speed:float = _velocity.length()
	if current_speed > SPEED:
		_velocity = _velocity.normalized() * previous_speed
	
	if _direction and project_velocity_on_direction:
		_velocity = _direction.normalized() * _velocity.length()

func update_look_direction(delta:float) -> void:
	var planar_direction = Vector3(_direction.x, 0, _direction.y)
	var planar_velocity = Vector3(_velocity.x, 0, _velocity.z)
	
	var current_look_angle = _look_angle
	var target_look_angle = _look_angle
	
	if planar_velocity:
		target_look_angle = -planar_velocity.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	elif planar_direction:
		target_look_angle = -planar_direction.signed_angle_to(Vector3.FORWARD, Vector3.UP)

	if target_look_angle - current_look_angle > PI:
		current_look_angle = current_look_angle + 2 * PI
	elif current_look_angle - target_look_angle > PI:
		current_look_angle = current_look_angle - 2 * PI

	if not is_player_controlled:
		DebugDraw2D.set_text("is_steering_active", str(is_steering_active))

	_look_angle = _look_angle_spring.calc(current_look_angle, target_look_angle, delta)

func _physics_process(delta: float) -> void:
	DebugDraw2D.set_text(name + ".is_steering_active", str(is_steering_active))
	DebugDraw2D.set_text(name + "._is_on_floor", str(_is_on_floor))

	_velocity = linear_velocity

	if is_player_controlled:
		_handle_player_controls(delta)
	elif is_steering_active:
		_direction = Vector3(steering_target.x - global_position.x, 0, steering_target.z - global_position.z)
		if _direction:
			_direction = _direction.normalized()
	else:
		_direction = Vector3.ZERO
	
	calc_desired_velocity(delta)
	
	update_look_direction(delta)
	
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
			
