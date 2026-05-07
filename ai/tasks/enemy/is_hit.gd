@tool
extends BTCondition
## Returns SUCCESS if the agent has been hit (is_hit blackboard flag is true).
## Returns FAILURE otherwise.
## The flag is set by the agent's take_damage() and cleared by PlayHitReaction.

@export var is_hit_var: StringName = &"is_hit"

func _generate_name() -> String:
	return "IsHit [%s]" % is_hit_var

func _setup() -> void:
	if not blackboard.has_var(is_hit_var):
		blackboard.set_var(is_hit_var, false)

func _tick(_delta: float) -> Status:
	if blackboard.get_var(is_hit_var, false, false):
		return SUCCESS
	return FAILURE
