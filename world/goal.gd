class_name Goal
extends Node3D

signal ball_detected(Goal, Ball)

# enums
enum TeamName {RED, BLUE}
@export var team_name: TeamName = TeamName.RED


func _on_ball_detector_body_entered(body: Node3D) -> void:
	var ball:Ball = body as Ball
	
	if not ball:
		return
	
	ball_detected.emit(self, ball)
