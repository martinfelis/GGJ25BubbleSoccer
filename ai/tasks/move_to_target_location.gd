extends BTAction

# constants
const target_location_var:StringName = &"target_location"
const steering_desired_distance:float = 1.2

# @export variables

func _tick(_delta: float) -> Status:
	var agent_soccer_player:SoccerPlayer = agent as SoccerPlayer
	if not is_instance_valid(agent_soccer_player):
		agent_soccer_player.is_steering_active = false
		push_warning("Invalid agent passed to Task %s." % get_task_name())
		return FAILURE
	
	var target_location:Vector3 = blackboard.get_var(target_location_var)
#	var target_distance = (agent_soccer_player.global_position - target_location).length()

	if (agent_soccer_player.global_position - target_location).length() < steering_desired_distance:
		agent_soccer_player.steering_target = agent_soccer_player.global_position
		agent_soccer_player.is_steering_active = false
		return SUCCESS
	
	DebugDraw3D.draw_line(agent.global_position, target_location, Color.RED)
	agent_soccer_player.steering_target = target_location
	agent_soccer_player.is_steering_active = true
	
	return RUNNING
