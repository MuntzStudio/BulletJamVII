@tool
extends BTAction
## Plays a hit reaction animation and clears the is_hit flag.
## Returns RUNNING until the animation duration elapses.
## Returns SUCCESS when done, allowing the BT to resume normal behaviour.

@export var is_hit_var: StringName = &"is_hit"
@export var reaction_duration: float = 0.3  # hit animation length

var _elapsed: float = 0.0

func _generate_name() -> String:
	return "PlayHitReaction (%.2fs)" % reaction_duration

func _enter() -> void:
	_elapsed = 0.0
	# Clear the flags so a second hit during recovery
	# can re-set it and trigger another reaction
	blackboard.set_var(is_hit_var, false)

func _tick(delta: float) -> Status:
	_elapsed += delta
	if _elapsed >= reaction_duration:
		return SUCCESS
	return RUNNING
