class_name SoccerPlayer
extends RigidBody3D

# signals

# enums

# constants
const SPEED:float = 10.0
const ACCEL:float = 34.0
const JUMP_VELOCITY:float = 4.5
const BOUNCE_ACCEL_TIMEOUT:float = 1

# @export variables
@export var project_velocity_on_direction:bool = true
@export var is_player_controlled:bool = false
# public variables

# private variables
var _velocity:Vector3 = Vector3.ZERO
var _bounce_timeout:float = 0

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	for i in range(state.get_contact_count()):
		var normal:Vector3 = state.get_contact_local_normal(i)
		# TODO: ensure we're not moving needlessliy against static geometry
	
	if is_player_controlled and _bounce_timeout == 0:
		state.linear_velocity = _velocity

func _handle_player_controls(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var previous_speed:float = _velocity.length()
	
	if direction:
		_velocity.x = _velocity.x + direction.x * ACCEL * delta
		_velocity.z = _velocity.z + direction.z * ACCEL * delta
	else:
		_velocity.x = move_toward(_velocity.x, 0, SPEED)
		_velocity.z = move_toward(_velocity.z, 0, SPEED)

	var current_speed:float = _velocity.length()
	if current_speed > SPEED:
		_velocity = _velocity.normalized() * previous_speed
	
	if direction and project_velocity_on_direction:
		_velocity = direction.normalized() * _velocity.length()

func _physics_process(delta: float) -> void:
	DebugDraw2D.set_text(name + " bounce timeout:", _bounce_timeout)

	if _bounce_timeout > 0:
		_bounce_timeout = _bounce_timeout - delta
		_bounce_timeout = max(0, _bounce_timeout)
		return

	_velocity = linear_velocity

	if is_player_controlled:
		_handle_player_controls(delta)

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
			
