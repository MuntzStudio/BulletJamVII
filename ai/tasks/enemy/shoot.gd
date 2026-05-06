@tool
extends BTAction
## Fires a burst of bullets toward the target.
## Returns RUNNING during burst.
## Returns SUCCESS when burst is complete (triggers reload).
## Returns FAILURE if target is invalid or no bullet scene set.

@export var target_var: StringName = &"target"
@export var bullet_scene: PackedScene
@export var fire_rate: float = 1.0
@export var burst_count: int = 3

var _fire_timer: float = 0.0
var _shots_fired: int = 0

func _generate_name() -> String:
	return "Shoot  %s  (burst: %d)" % [LimboUtility.decorate_var(target_var), burst_count]

func _tick(delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE
	if bullet_scene == null:
		return FAILURE

	_fire_timer -= delta
	if _fire_timer > 0.0:
		return RUNNING

	_fire_timer = fire_rate

	var spawn: Marker3D = agent.find_child("BulletSpawn")
	var bullet = bullet_scene.instantiate()
	agent.get_tree().current_scene.add_child(bullet)
	bullet.global_position = spawn.global_position
	var dir := (target.global_position - spawn.global_position).normalized()
	dir.y = 0.0
	bullet.launch(dir)
	_shots_fired += 1

	if _shots_fired >= burst_count:
		_shots_fired = 0  
		return SUCCESS

	return RUNNING
