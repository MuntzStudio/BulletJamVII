@tool
extends BTAction
## Plays a hit reaction animation and clears the is_hit flag.
## Drives the Blend2_Hit layer in AnimationTree to full override on enter,
## resets it on exit so normal locomotion resumes.
## Returns RUNNING until the animation duration elapses.
## Returns SUCCESS when done.

@export var is_hit_var: StringName = &"is_hit"
@export var anim_tree_path: NodePath = ^"AnimationTree"
@export var hit_blend_param: String = "parameters/Blend2_Hit/blend_amount"
@export var reaction_duration: float = 0.3  # match your hit animation length

var _anim_tree: AnimationTree
var _elapsed: float = 0.0

func _generate_name() -> String:
	return "PlayHitReaction (%.2fs)" % reaction_duration

func _setup() -> void:
	_anim_tree = agent.get_node_or_null(anim_tree_path)

func _enter() -> void:
	_elapsed = 0.0
	# Clear flag immediately so a second hit during recovery re-triggers
	blackboard.set_var(is_hit_var, false)
	# Override all layers with hit animation
	if _anim_tree:
		_anim_tree.set(hit_blend_param, 1.0)

func _exit() -> void:
	# Hands control back to locomotion + shoot layers
	if _anim_tree:
		_anim_tree.set(hit_blend_param, 0.0)

func _tick(delta: float) -> Status:
	_elapsed += delta
	if _elapsed >= reaction_duration:
		return SUCCESS
	return RUNNING
