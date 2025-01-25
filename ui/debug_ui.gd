extends Control

@onready var behavior_tree_view: BehaviorTreeView = %BehaviorTreeView

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update_behaviour_tree_entity_state() -> void:
	var npc_entities = get_tree().get_nodes_in_group("NPCPlayer")
	if npc_entities.size() == 0:
		return
	
	var debug_soccer_player:SoccerPlayer = npc_entities[0] as SoccerPlayer
	if not is_instance_valid(debug_soccer_player):
		push_error("Invalid entity in NPCPlayer group!")
		return
	
	var tree_instance:BTInstance = debug_soccer_player.bt_player.get_bt_instance()
	behavior_tree_view.update_tree(BehaviorTreeData.create_from_bt_instance(tree_instance))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_behaviour_tree_entity_state()
