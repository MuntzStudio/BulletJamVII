@tool
extends BTAction
## Sets an AnimationTree parameter to on_value on enter, resets to off_value on exit.
## Useful for blending in/out animation layers (shoot, hit etc).
## Returns RUNNING forever - pair it in a Parallel with the action that should own the duration.

@export var anim_tree_path: NodePath = ^"AnimationTree"
@export var parameter: String = "parameters/Blend2/blend_amount"
@export var on_value: float = 1.0
@export var off_value: float = 0.0

var _anim_tree: AnimationTree

func _generate_name() -> String:
	return "SetAnimTreeParam  \"%s\"  →  %.1f" % [parameter, on_value]

func _setup() -> void:
	_anim_tree = agent.get_node_or_null(anim_tree_path)

func _enter() -> void:
	if _anim_tree:
		_anim_tree.set(parameter, on_value)

func _exit() -> void:
	if _anim_tree:
		_anim_tree.set(parameter, off_value)

func _tick(_delta: float) -> Status:
	# Just keeps RUNNING so the Parallel parent controls the lifetime
	return RUNNING
