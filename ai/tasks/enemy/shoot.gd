@tool
extends BTAction
## Fires projectiles toward target.
## Supports:
## - normal bullets
## - boomerang projectiles

@export var target_var: StringName = &"target"
@export var bullet_scene: PackedScene
@export var fire_rate: float = 1.0
@export var burst_count: int = 3
@export var boomerang_sfx = AudioStream
@export var bullet_sfx = AudioStream

# Max active boomerangs per enemy
@export var max_boomerangs: int = 4

var _fire_timer: float = 0.0
var _shots_fired: int = 0


func _generate_name() -> String:
	return "Shoot %s (burst: %d)" % [
		LimboUtility.decorate_var(target_var),
		burst_count
	]


func _tick(delta: float) -> Status:

	# ==================================================
	# TARGET CHECK
	# ==================================================
	var target: Node3D = blackboard.get_var(target_var, null)

	if not is_instance_valid(target):
		return FAILURE

	if bullet_scene == null:
		return FAILURE


	# ==================================================
	# FIRE TIMER
	# ==================================================
	_fire_timer -= delta

	if _fire_timer > 0.0:
		return RUNNING

	_fire_timer = fire_rate


	# ==================================================
	# SPAWN POINT
	# ==================================================
	var spawn: Node3D = agent.find_child("BulletSpawn")

	if spawn == null:
		return FAILURE


	# ==================================================
	# TEMP INSTANCE
	# ==================================================
	var temp = bullet_scene.instantiate()

	var is_boomerang := false

	if "is_boomerang" in temp:
		is_boomerang = temp.is_boomerang


	# ==================================================
	# BOOMERANG PROJECTILES
	# ==================================================
	if is_boomerang:

		# ----------------------------------------------
		# COUNT ACTIVE BOOMERANGS
		# ----------------------------------------------
		var active_count := 0

		for node in agent.get_tree().get_nodes_in_group(
			"boomerang"
		):

			if node.get_meta("thrower", null) == agent:
				active_count += 1


		if active_count >= max_boomerangs:

			temp.queue_free()

			return RUNNING


		temp.queue_free()


		# ----------------------------------------------
		# LEFT BOOMERANG
		# ----------------------------------------------
		var left_boomerang = bullet_scene.instantiate()

		agent.get_tree().current_scene.add_child(
			left_boomerang
		)
		left_boomerang.global_position = (
			spawn.global_position
		)

		if boomerang_sfx:
			Audio.play_sound_3d(boomerang_sfx,agent.global_position)

		left_boomerang.setup(
			agent,
			target,
			1.0
		)


		# ----------------------------------------------
		# RIGHT BOOMERANG
		# ----------------------------------------------
		var right_boomerang = bullet_scene.instantiate()

		agent.get_tree().current_scene.add_child(
			right_boomerang
		)
		right_boomerang.global_position = (
			spawn.global_position
		)

		if boomerang_sfx:
			Audio.play_sound_3d(boomerang_sfx,agent.global_position)

		right_boomerang.setup(
			agent,
			target,
			-1.0
		)


	# ==================================================
	# NORMAL PROJECTILES
	# ==================================================
	else:

		temp.queue_free()

		var bullet = bullet_scene.instantiate()



		agent.get_tree().current_scene.add_child(bullet)

		bullet.global_position = spawn.global_position

		if bullet_sfx:
			Audio.play_sound_3d(bullet_sfx,agent.global_position)

		var dir := target.global_position - spawn.global_position
		dir.y = 0.0
		dir = dir.normalized()

		bullet.launch(dir)

	# ==================================================
	# BURST TRACKING
	# ==================================================
	_shots_fired += 1

	if _shots_fired >= burst_count:

		_shots_fired = 0

		return SUCCESS


	return RUNNING
