extends BTAction

const ball_location_var:StringName = &"ball_location"

func _tick(_delta: float) -> Status:
	var ball_objects:Array = agent.get_tree().get_nodes_in_group("Ball")
	if ball_objects.size() == 0:
		breakpoint
		return FAILURE
	
	var agent_soccer_player:SoccerPlayer = agent as SoccerPlayer
	if not is_instance_valid(agent_soccer_player):
		agent_soccer_player.is_steering_active = false
		push_warning("Invalid agent passed to Task %s." % get_task_name())
		return FAILURE
	
	var closest_distance:float = INF
	var closest_index:int = 0
	for i in range(ball_objects.size()):
		var ball:Ball = ball_objects[i] as Ball
		
		# Ignore balls that are connected to team members
		if ball.connected_player and ball.connected_player.team_name == agent_soccer_player.team_name:
			continue
		
		if agent_soccer_player.team_name == SoccerPlayer.TeamName.RED:
			if ball.ignore_timer_red > 0:
				continue
		else:
			if ball.ignore_timer_blue > 0:
				continue
		
		var distance:float = (ball.global_position - agent.global_position).length()
		if distance < closest_distance:
			closest_distance = distance
			closest_index = i
	
	blackboard.set_var(ball_location_var, ball_objects[closest_index].global_position)
	
	return SUCCESS
