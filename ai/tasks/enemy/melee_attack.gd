@tool
extends BTAction
## Performs a melee attack on the target.
## Returns SUCCESS when attack animation is complete.
## Returns FAILURE if target is not a valid Node3D instance.


@export var target_var: StringName = &"target"
@export var damage: float = 10.0
@export var lunge_speed: float = 50.0

var _lunge_dir: Vector3 = Vector3.ZERO

func _enter() -> void:
	agent.anim_player.play("attack")
	_lunge_dir = -agent.basis.z
	_lunge_dir.y = 0.0
	agent.velocity.x = _lunge_dir.x * lunge_speed
	agent.velocity.z = _lunge_dir.z * lunge_speed

func _tick(_delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE
	# Let enemy.friction handle slowdown naturally
	agent.apply_friction()
	var anim_player: AnimationPlayer = agent.get_node("AnimationPlayer")
	if anim_player.is_playing():
		return RUNNING
	if target.has_method("take_damage"):
		target.take_damage(damage)
	return SUCCESS
