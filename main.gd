extends Control

@onready var sub_viewport: SubViewport = %SubViewport
@onready var game: Game = %Game

@onready var blue_score_label: Label = %BlueScoreLabel
@onready var red_score_label: Label = %RedScoreLabel

func _ready():
	game.score_updated.connect(on_score_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	DebugDraw3D.scoped_config().set_viewport(sub_viewport)

func on_score_updated() -> void:
	blue_score_label.text = str(game.blue_score)
	red_score_label.text = str(game.red_score)
