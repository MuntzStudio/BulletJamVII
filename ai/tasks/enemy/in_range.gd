@tool
extends BTCondition
## Returns SUCCESS if agent is within range of target.
## Returns FAILURE if out of range or target is invalid.

@export var range_min: float = 3.0
@export var range_max: float = 5.0
@export var target_var: StringName = &"target"

var _min_sq: float
var _max_sq: float

func _generate_name() -> String:
	return "InRange (%.1f, %.1f) of %s" % [
		range_min, range_max,
		LimboUtility.decorate_var(target_var)
	]

func _setup() -> void:
	_min_sq = range_min * range_min
	_max_sq = range_max * range_max

func _tick(_delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE
	
	# Ignore height difference
	var a : Vector3 = agent.global_position
	var b : Vector3 = target.global_position
	var dist_sq := Vector2(a.x - b.x, a.z - b.z).length_squared()
	if dist_sq >= _min_sq and dist_sq <= _max_sq:
		return SUCCESS
	return FAILURE
