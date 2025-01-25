extends BTAction

# constants
const target_location_var:StringName = &"target_location"
const BALL_PREDICTION_MIN_DISTANCE = 0.5
const BALL_PREDICTION_MAX_DISTANCE = 3

func find_goal(soccer_player:SoccerPlayer) -> Goal:
	var target_goal:Goal = null
	var goal_objects:Array = agent.get_tree().get_nodes_in_group("Goal")
	for goal:Goal in goal_objects:
		if goal.team_name != soccer_player.team_name:
			target_goal = goal
	
	return target_goal

func find_closest_ball() -> Ball:
	var ball_objects:Array = agent.get_tree().get_nodes_in_group("Ball")
	assert(ball_objects.size() > 0)
	
	var closest_distance:float = INF
	var closest_index:int = 0
	for i in range(ball_objects.size()):
		var distance:float = (ball_objects[i].global_position - agent.global_position).length()
		if distance < closest_distance:
			closest_distance = distance
			closest_index = i
	
	return ball_objects[closest_index] as Ball

func _tick(_delta: float) -> Status:
	var agent_soccer_player:SoccerPlayer = agent as SoccerPlayer
	if not is_instance_valid(agent_soccer_player):
		agent_soccer_player.is_steering_active = false
		push_warning("Invalid agent passed to Task %s." % get_task_name())
		return FAILURE
	
	var goal:Goal = find_goal(agent_soccer_player)
	var ball:Ball = find_closest_ball()
		
	if goal == null:
		push_warning("Could not find goal!")
		return FAILURE

	if ball == null:
		push_warning("Could not find ball!")
		return FAILURE	

	var ball_distance = (ball.global_position - agent.global_position).length()
	var predicted_ball_location:Vector3 = ball.global_position + ball.linear_velocity * 0.1 * clampf((ball_distance - BALL_PREDICTION_MIN_DISTANCE) / (BALL_PREDICTION_MAX_DISTANCE - BALL_PREDICTION_MIN_DISTANCE), 0, 1)
	var target_location = predicted_ball_location + (predicted_ball_location - ball.global_position).normalized() * 2
	blackboard.set_var(target_location_var, target_location)
	DebugDraw3D.draw_arrow(agent.global_position, target_location, Color.ORANGE, 0.1, true)
		
	return SUCCESS
