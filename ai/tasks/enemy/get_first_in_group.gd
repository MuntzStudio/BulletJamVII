@tool
extends BTAction
## Gets the first node in the group and stores it on the blackboard.
## Returns SUCCESS if found, FAILURE if group is empty.

@export var group: StringName = &"player"
@export var output_var: StringName = &"target"

func _generate_name() -> String:
	return "GetFirstInGroup  \"%s\"  ➜ %s" % [
		group,
		LimboUtility.decorate_var(output_var)
	]

func _tick(_delta: float) -> Status:
	var nodes := agent.get_tree().get_nodes_in_group(group)
	if nodes.size() == 0:
		return FAILURE
	blackboard.set_var(output_var, nodes[0])
	return SUCCESS
