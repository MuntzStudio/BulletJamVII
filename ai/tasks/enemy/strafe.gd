@tool
extends BTAction
## Strafes perpendicular to the target, then pauses briefly.
## Returns RUNNING while strafing or pausing.

@export var target_var: StringName = &"target"
@export var speed_var: StringName = &"speed"
@export var strafe_duration: float = 1.0
@export var pause_duration: float = 0.5
@export var rotation_speed: float = 0.1

var _timer: float = 0.0
var _is_pausing: bool = false
var _strafe_dir: Vector3 = Vector3.ZERO

func _generate_name() -> String:
	return "Strafe around %s" % LimboUtility.decorate_var(target_var)

func _enter() -> void:
	_timer = 0.0
	_is_pausing = false
	_pick_strafe_dir()

func _pick_strafe_dir() -> void:
	# Pick left or right perpendicular to target randomly
	var to_target : Vector3 = agent.global_position.direction_to(
		blackboard.get_var(target_var, null).global_position
	)
	to_target.y = 0.0
	var perp := to_target.cross(Vector3.UP)
	_strafe_dir = perp if randf() > 0.5 else -perp

func _tick(delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	# Always face target
	var dir_to_target : Vector3 = agent.global_position.direction_to(target.global_position)
	dir_to_target.y = 0.0
	if dir_to_target != Vector3.ZERO:
		var target_basis := Basis.looking_at(-dir_to_target)
		agent.basis = agent.basis.slerp(target_basis, rotation_speed)

	_timer += delta

	if _is_pausing:
		agent.apply_friction()
		if _timer >= pause_duration:
			return SUCCESS
	else:
		var speed: float = blackboard.get_var(speed_var, 3.5)
		# Set nav target to a point in the strafe direction
		var strafe_target : Vector3 = agent.global_position + _strafe_dir * 3.0
		agent.navigation_agent.target_position = strafe_target
		var next_pos : Vector3 = agent.navigation_agent.get_next_path_position()
		var nav_dir : Vector3 = agent.global_position.direction_to(next_pos)
		nav_dir.y = 0.0
		agent.move(nav_dir * speed)
		if _timer >= strafe_duration:
			_is_pausing = true
			_timer = 0.0

	return RUNNING
