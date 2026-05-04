@tool
extends BTAction
## Moves the agent away from the target when too close.
## Returns RUNNING while backing away.
## Returns FAILURE if target is invalid.

@export var target_var: StringName = &"target"
@export var speed_var: StringName = &"speed"
@export var safe_distance: float = 10.0
@export var rotation_speed: float = 0.1

@export var retarget_interval: float = 0.3 
var _safe_sq: float
var _time_since_retarget: float = 0.0

func _generate_name() -> String:
	return "BackAway from %s" % LimboUtility.decorate_var(target_var)

func _setup() -> void:
	_safe_sq = safe_distance * safe_distance

func _tick(delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var a: Vector3 = agent.global_position
	var b: Vector3 = target.global_position
	var dist_sq := Vector2(a.x - b.x, a.z - b.z).length_squared()

	# Always face player
	var dir_to_target: Vector3 = (b - a)
	dir_to_target.y = 0.0
	if dir_to_target != Vector3.ZERO:
		dir_to_target = dir_to_target.normalized()
		agent.basis = agent.basis.slerp(Basis.looking_at(-dir_to_target), rotation_speed)

	if dist_sq >= _safe_sq:
		agent.apply_friction()
		return RUNNING

	# Only recompute nav target on interval
	_time_since_retarget += delta
	if _time_since_retarget >= retarget_interval:
		_time_since_retarget = 0.0
		var away_dir: Vector3 = -dir_to_target
		agent.navigation_agent.target_position = a + away_dir * safe_distance

	var speed: float = blackboard.get_var(speed_var, 3.5)
	var next_pos: Vector3 = agent.navigation_agent.get_next_path_position()
	agent.move(agent.global_position.direction_to(next_pos) * speed)

	return RUNNING
