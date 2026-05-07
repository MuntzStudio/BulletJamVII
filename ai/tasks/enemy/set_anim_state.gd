@tool
extends BTAction
## Travels to a state in an AnimationTree StateMachine.
## Returns SUCCESS immediately after requesting the travel.
## Returns FAILURE if the AnimationTree or StateMachine is not found.

@export var anim_tree_path: NodePath = ^"AnimationTree"
@export var state_machine_param: String = "parameters/Locomotion/playback"
@export var state: String = "Idle"

var _anim_tree: AnimationTree

func _generate_name() -> String:
	return "SetAnimState  \"%s\"" % state

func _setup() -> void:
	_anim_tree = agent.get_node_or_null(anim_tree_path)

func _tick(_delta: float) -> Status:
	if _anim_tree == null:
		return FAILURE

	var playback = _anim_tree.get(state_machine_param)
	if playback == null:
		return FAILURE

	playback.travel(state)
	return SUCCESS
