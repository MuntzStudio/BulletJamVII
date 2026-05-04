@tool
extends BTAction
## Rotates the agent to face the target.
## Returns SUCCESS if target is valid.
## Returns FAILURE if target is not a valid Node3D instance.

@export var target_var: StringName = &"target"
@export var rotation_speed: float = 0.1
@export var alignment_threshold: float = 0.99

func _generate_name() -> String:
	return "FaceTarget  %s" % LimboUtility.decorate_var(target_var)

func _tick(_delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var dir: Vector3 = agent.global_position.direction_to(target.global_position)
	dir.y = 0.0

	if dir == Vector3.ZERO:
		return SUCCESS

	var target_basis: Basis = Basis.looking_at(-dir)
	agent.basis = agent.basis.slerp(target_basis, rotation_speed)

	# Check how aligned we are using dot product
	var current_forward: Vector3 = -agent.basis.z
	if current_forward.dot(-dir) >= alignment_threshold:
		return SUCCESS

	return RUNNING
