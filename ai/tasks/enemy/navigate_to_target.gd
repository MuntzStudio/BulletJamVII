@tool
extends BTAction
## Moves the agent toward the target using NavigationAgent3D.
## Returns RUNNING while moving, SUCCESS when within stopping distance.
## Returns FAILURE if target is invalid.

@export var target_var: StringName = &"target"
@export var speed_var: StringName = &"speed"
@export var stopping_distance: float = 8.0
@export var rotation_speed: float = 0.1
@export var retarget_interval: float = 0.2

var _time_since_retarget: float = 0.0


func _tick(delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var speed: float = blackboard.get_var(speed_var, 3.5)

	# Retarget at interval for performance
	_time_since_retarget += delta
	if _time_since_retarget >= retarget_interval:
		_time_since_retarget = 0.0
		agent.navigation_agent.target_position = target.global_position

	# Stopping distance
	var a: Vector3 = agent.global_position
	var b: Vector3 = target.global_position
	var dist_sq := Vector2(a.x - b.x, a.z - b.z).length_squared()
	if dist_sq <= (stopping_distance - 2.0) * (stopping_distance - 2.0):
		return SUCCESS

	# Smooth rotation toward target while moving
	var dir_to_target: Vector3 = agent.global_position.direction_to(target.global_position)
	dir_to_target.y = 0.0
	if dir_to_target != Vector3.ZERO:
		var target_basis: Basis = Basis.looking_at(dir_to_target)
		agent.basis = agent.basis.slerp(target_basis, rotation_speed)

	var next_pos: Vector3 = agent.navigation_agent.get_next_path_position()
	var dir: Vector3 = agent.global_position.direction_to(next_pos)
	dir.y = 0.0
	agent.move(dir * speed)
	return RUNNING
