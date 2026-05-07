@tool
extends BTAction
## Performs a melee attack on the target.
## Returns SUCCESS when the lunge duration has elapsed.
## Returns FAILURE if target is not a valid Node3D instance.

@export var target_var: StringName = &"target"
@export var damage: float = 10.0
@export var lunge_speed: float = 50.0
@export var lunge_duration: float = 0.4  # how long it holds the lunge before SUCCESS

var _lunge_dir: Vector3 = Vector3.ZERO
var _locked_basis: Basis
var _elapsed: float = 0.0
var _damage_dealt: bool = false

func _enter() -> void:
	_elapsed = 0.0
	_damage_dealt = false

	# Snapshots the forward direction at the moment of attack
	_lunge_dir = agent.basis.z
	_lunge_dir.y = 0.0

	# Lock the dir so nothing can rotate the agent during the lunge
	_locked_basis = agent.basis

	agent.velocity.x = _lunge_dir.x * lunge_speed
	agent.velocity.z = _lunge_dir.z * lunge_speed

func _tick(delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	# Enforce the locked rotation every tick
	agent.basis = _locked_basis

	agent.apply_friction()

	# Deal damage once, on the first tick
	if not _damage_dealt:
		if target.has_method("take_damage"):
			target.take_damage(damage)
		_damage_dealt = true

	_elapsed += delta
	if _elapsed >= lunge_duration:
		return SUCCESS

	return RUNNING
