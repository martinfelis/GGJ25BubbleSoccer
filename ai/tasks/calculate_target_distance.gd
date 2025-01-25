extends BTAction

const target_location_var:StringName = &"target_location"
const target_distance_var:StringName = &"target_distance"

func _tick(_delta: float) -> Status:
	var target_location:Vector3 = blackboard.get_var(target_location_var)
	
	blackboard.set_var(target_distance_var, (target_location - agent.global_position).length())
	
	return SUCCESS
