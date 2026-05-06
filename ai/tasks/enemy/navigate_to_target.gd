@tool
extends BTAction
## Moves the agent toward the target using NavigationAgent3D.
## Phase 1: Navigate to a random point on a ring around the target.
## Phase 2: Optionally close in to stopping distance (melee) or hold ring (ranged).
## Returns RUNNING while moving, SUCCESS when in position.
## Returns FAILURE if target is invalid.

@export var target_var: StringName = &"target"
@export var speed_var: StringName = &"speed"
@export var stopping_distance: float = 2.0
@export var rotation_speed: float = 0.1
@export var ring_min: float = 5.0
@export var ring_max: float = 10.0
@export var approach_after_offset: bool = true  # melee = true, ranged = false
@export var retarget_interval: float = 2.0
@export var use_stamina: bool = false
@export var sprint_speed_multiplier: float = 1.5
@export var tired_speed_multiplier: float = 0.3
@export var sprint_duration: float = 3.0
@export var tired_duration: float = 1.5

var _stamina_timer: float = 0.0
var _is_tired: bool = false
var _time_since_retarget: float = 0.0
var _at_ring: bool = false  # reached the ring point
var _ring_point: Vector3 = Vector3.ZERO

func _enter() -> void:
	pass  # persist state across re-entries

func _roll_ring_point(target_pos: Vector3) -> void:
	var angle := randf() * TAU
	var dist := randf_range(ring_min, ring_max)
	var offset := Vector3(cos(angle), 0.0, sin(angle)) * dist
	_ring_point = target_pos + offset
	agent.navigation_agent.target_position = _ring_point
	_at_ring = false

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
	var a: Vector3 = agent.global_position
	var b: Vector3 = target.global_position

	# Always face target
	var dir_to_target: Vector3 = (b - a)
	dir_to_target.y = 0.0
	if dir_to_target != Vector3.ZERO:
		dir_to_target = dir_to_target.normalized()
		agent.basis = agent.basis.slerp(Basis.looking_at(-dir_to_target), rotation_speed)

	# Reroll ring point on interval
	_time_since_retarget += delta
	if _time_since_retarget >= retarget_interval:
		_time_since_retarget = 0.0
		_roll_ring_point(b)

	var dist_sq := Vector2(a.x - b.x, a.z - b.z).length_squared()


	# Phase 2: approach after reaching ring (melee only)
	if _at_ring and approach_after_offset:
		agent.navigation_agent.target_position = b
		if dist_sq <= stopping_distance * stopping_distance:
			return SUCCESS
		var next_pos: Vector3 = agent.navigation_agent.get_next_path_position()
		var dir: Vector3 = a.direction_to(next_pos)
		dir.y = 0.0
		agent.move(dir * speed * _update_stamina(delta))
		return RUNNING

	# Phase 1: navigate to ring point
	if not _at_ring:
		var to_ring_sq := Vector2(
			a.x - _ring_point.x,
			a.z - _ring_point.z
		).length_squared()
		if to_ring_sq <= 1.0:
			_at_ring = true
			if not approach_after_offset:
				return SUCCESS  # ranged: hold here, let fire cycle do its thing
		else:
			var next_pos: Vector3 = agent.navigation_agent.get_next_path_position()
			var dir: Vector3 = a.direction_to(next_pos)
			dir.y = 0.0
			agent.move(dir * speed * _update_stamina(delta))

	return RUNNING
