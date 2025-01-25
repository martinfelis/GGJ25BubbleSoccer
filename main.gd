extends Control

@onready var sub_viewport: SubViewport = %SubViewport

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	DebugDraw3D.scoped_config().set_viewport(sub_viewport)
