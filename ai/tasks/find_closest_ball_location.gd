extends BTAction

const target_location_var:StringName = &"target_location"

func _tick(_delta: float) -> Status:
	var ball_objects:Array = agent.get_tree().get_nodes_in_group("Ball")
	if ball_objects.size() == 0:
		breakpoint
		return FAILURE
	
	var closest_distance:float = INF
	var closest_index:int = 0
	for i in range(ball_objects.size()):
		var distance:float = (ball_objects[i].global_position - agent.global_position).length()
		if distance < closest_distance:
			closest_distance = distance
			closest_index = i
	
	blackboard.set_var(target_location_var, ball_objects[closest_index].global_position)
	
	return SUCCESS
