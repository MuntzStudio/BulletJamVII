@tool
extends BTAction
## Moves the agent toward the target using NavigationAgent3D.
## Returns RUNNING while moving, SUCCESS when within stopping distance.
## Returns FAILURE if target is invalid.

@export var target_var: StringName = &"target"
@export var speed_var: StringName = &"speed"
@export var stopping_distance: float = 8.0
@export var rotation_speed: float = 0.1
@export var retarget_interval: float = 2.0
@export var separation_radius: float = 5.0
@export var use_stamina: bool = false
@export var sprint_speed_multiplier: float = 1.5
@export var tired_speed_multiplier: float = 0.3
@export var sprint_duration: float = 3.0
@export var tired_duration: float = 1.5

var _stamina_timer: float = 0.0
var _is_tired: bool = false
var _time_since_retarget: float = 0.0
var _at_offset: bool = false

func _enter() -> void:
	_time_since_retarget = retarget_interval
	_at_offset = false

func _roll_new_offset(target_pos: Vector3) -> void:
	var angle := randf() * TAU
	var offset := Vector3(cos(angle), 0.0, sin(angle)) * separation_radius
	agent.navigation_agent.target_position = target_pos + offset

func _update_stamina(delta: float) -> float:
	if not use_stamina:
		return 1.0
	_stamina_timer += delta
	if not _is_tired and _stamina_timer >= sprint_duration:
		_is_tired = true
		_stamina_timer = 0.0
	elif _is_tired and _stamina_timer >= tired_duration + randf() * 0.5:
		_is_tired = false
		_stamina_timer = 0.0
	return tired_speed_multiplier if _is_tired else sprint_speed_multiplier

func _tick(delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var speed: float = blackboard.get_var(speed_var, 3.5)

	# Reroll next pos every interval
	_time_since_retarget += delta
	if _time_since_retarget >= retarget_interval:
		_time_since_retarget = 0.0
		_at_offset = false
		_roll_new_offset(target.global_position)

	# Check if reached current offset position
	if not _at_offset:
		var to_offset_sq := Vector2(
			agent.global_position.x - agent.navigation_agent.target_position.x,
			agent.global_position.z - agent.navigation_agent.target_position.z
		).length_squared()
		if to_offset_sq <= 1.0:
			_at_offset = true

	# Switch to attack when close enough to player
	var a: Vector3 = agent.global_position
	var b: Vector3 = target.global_position
	var dist_sq := Vector2(a.x - b.x, a.z - b.z).length_squared()
	if dist_sq <= (stopping_distance - 2.0) * (stopping_distance - 2.0):
		return SUCCESS

	# Only move if not yet at offset
	if not _at_offset:
		var dir_to_target: Vector3 = agent.global_position.direction_to(target.global_position)
		dir_to_target.y = 0.0
		if dir_to_target != Vector3.ZERO:
			var target_basis: Basis = Basis.looking_at(dir_to_target)
			agent.basis = agent.basis.slerp(target_basis, rotation_speed)

		var next_pos: Vector3 = agent.navigation_agent.get_next_path_position()
		var dir: Vector3 = agent.global_position.direction_to(next_pos)
		dir.y = 0.0
		var multiplier := _update_stamina(delta)
		agent.move(dir * speed * multiplier)

	return RUNNING
