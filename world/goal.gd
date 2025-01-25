class_name Goal
extends Node3D

const BLUE_MATERIAL:Material = preload("res://materials/team_blue_material.tres")
const RED_MATERIAL:Material = preload("res://materials/team_red_material.tres")

signal ball_detected(Goal, Ball)

@onready var geometry: CSGBox3D = %Geometry

# enums
enum TeamName {RED, BLUE}
@export var team_name: TeamName :
	set(value):
		team_name = value
		update_team()
	get:
		return team_name

func _ready() -> void:
	update_team()

func update_team():
	if not is_instance_valid(geometry):
		return
		
	if team_name == TeamName.RED:
		geometry.material_override = RED_MATERIAL
	else:
		geometry.material_override = BLUE_MATERIAL

func _on_ball_detector_body_entered(body: Node3D) -> void:
	var ball:Ball = body as Ball
	
	if not ball:
		return
	
	ball_detected.emit(self, ball)
