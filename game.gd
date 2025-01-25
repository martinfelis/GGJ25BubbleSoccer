class_name Game
extends Node3D

@onready var camera_3d: Camera3D = %Camera3D

var _camera_offset:Vector3 = Vector3.UP * 10 + Vector3.BACK * 5# + Vector3.RIGHT * 10
var _camera_center:Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_camera_offset = camera_3d.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for soccer_player:SoccerPlayer in get_tree().get_nodes_in_group("SoccerPlayer"):
		# TODO: extend for multiple player controlled soccer players
		if soccer_player.is_player_controlled:
			_camera_center = soccer_player.global_position
	
	camera_3d.global_position = _camera_center + _camera_offset
	camera_3d.look_at(_camera_center)
	
