extends RigidBody3D

# signals

# enums

# constants
const SPEED:float = 10.0
const ACCEL:float = 34.0
const JUMP_VELOCITY:float = 4.5
const BOUNCE_ACCEL_TIMEOUT:float = 0.2

# @export variables
@export var PROJECT_VELOCITY_ON_DIRECTION:bool = true

# public variables

# private variables
var _velocity:Vector3 = Vector3.ZERO
var _bounce_timeout:float = 0

# @onready variables
@onready var ground: Node3D = %Ground

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity = _velocity

func _physics_process(delta: float) -> void:
	if _bounce_timeout > 0:
		_bounce_timeout = _bounce_timeout - delta
		return

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"): # and is_on_floor():
		_velocity.y = JUMP_VELOCITY

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
	
	if direction and PROJECT_VELOCITY_ON_DIRECTION:
		_velocity = direction.normalized() * _velocity.length()
#		var direction_correction = min(1.0, delta / VELOCITY_DIRECTION_CORRECTION_PER_SECOND)
#		_velocity = lerp(_velocity, direction.normalized() * _velocity.length(), direction_correction)
	
func _on_body_entered(body: Node) -> void:
	if body == ground:
		pass

	var other_rigid_body:RigidBody3D = body as RigidBody3D
	if other_rigid_body:
		var vector_to_body:Vector3 = body.global_position - global_position
		vector_to_body.y = 0
		DebugDraw3D.draw_arrow(Vector3.UP, body.global_position + Vector3.UP, Color.RED, 0.4, true, 2.0)
		other_rigid_body.apply_impulse((vector_to_body).normalized() * 2)

	_velocity = Vector3.ZERO
	#_bounce_timeout = BOUNCE_ACCEL_TIMEOUT
