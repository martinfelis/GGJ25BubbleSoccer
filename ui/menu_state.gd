class_name MenuState
extends Node

@onready var ui_control:Control = null
@export var ui_control_path:NodePath = ""

func _ready():
	ui_control = get_node(ui_control_path) as Control
	assert (is_instance_valid(ui_control))

func enter():
	print ("Entering state %s" % name)
	ui_control.show()
	ui_control.process_mode = Node.PROCESS_MODE_INHERIT	

func leave():
	print ("Leaving state %s" % name)
	ui_control.process_mode = Node.PROCESS_MODE_DISABLED
	ui_control.hide()
