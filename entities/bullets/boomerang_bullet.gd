extends CharacterBody3D

@export var is_boomerang := true

@export var throw_speed: float = 20.0
@export var return_speed: float = 22.0

# Strong curve after initial attack
@export var curve_force: float = 45.0

# Initial direct attack phase duration
@export var attack_time: float = 0.42

# Total outward travel before forced return
@export var outward_time: float = 0.8

@export var spin_speed: float = 30.0

# Max wall bounces BEFORE return
@export var max_bounces: int = 1


@onready var hitbox = $Hitbox


var thrower: Node3D
var target: Node3D

var curve_direction: Vector3 = Vector3.ZERO
var predicted_target: Vector3 = Vector3.ZERO

var timer: float = 0.0
var returning: bool = false

var bounce_count: int = 0


func _ready() -> void:

	add_to_group("boomerang")

	hitbox.set_active(true)


func setup(
	_thrower: Node3D,
	_target: Node3D,
	curve_sign: float = 1.0
) -> void:

	thrower = _thrower
	target = _target

	set_meta("thrower", thrower)

	global_position = thrower.global_position


	# ==================================================
	# PREDICT PLAYER MOVEMENT
	# ==================================================
	var player_velocity := Vector3.ZERO

	if target is CharacterBody3D:
		player_velocity = target.velocity


	predicted_target = (
		target.global_position +
		player_velocity * 0.45
	)


	# ==================================================
	# AIM TOWARD FUTURE PLAYER POSITION
	# ==================================================
	var dir = (
		predicted_target - thrower.global_position
	).normalized()

	dir.y = 0.0


	# ==================================================
	# INITIAL THROW VELOCITY
	# ==================================================
	velocity = dir * throw_speed


	# ==================================================
	# CURVE DIRECTION
	# ==================================================
	curve_direction = Vector3(-dir.z, 0.0, dir.x)

	curve_direction *= curve_sign


func _physics_process(delta: float) -> void:

	# ==================================================
	# SAFETY
	# ==================================================
	if not is_instance_valid(thrower):
		queue_free()
		return


	timer += delta


	# ==================================================
	# OUTWARD PHASE
	# ==================================================
	if not returning:

		# ----------------------------------------------
		# START CURVING AFTER ATTACK PHASE
		# ----------------------------------------------
		if timer >= attack_time:

			velocity += curve_direction * curve_force * delta


		# ----------------------------------------------
		# CLAMP SPEED
		# ----------------------------------------------
		if velocity.length() > throw_speed:

			velocity = velocity.normalized() * throw_speed


		# ----------------------------------------------
		# MOVE WITH COLLISION
		# ----------------------------------------------
		var collision = move_and_collide(
			velocity * delta
		)


		# ----------------------------------------------
		# WALL HIT
		# ----------------------------------------------
		if collision:

			var collider = collision.get_collider()


			# Ignore player/enemy collisions
			if not collider.is_in_group("enemy") \
			and not collider.is_in_group("player"):


				bounce_count += 1


				# --------------------------------------
				# FIRST BOUNCE
				# --------------------------------------
				if bounce_count <= max_bounces:

					velocity = velocity.bounce(
						collision.get_normal()
					)

					# Slight energy loss
					velocity *= 0.9


				# --------------------------------------
				# SECOND WALL HIT -> RETURN
				# --------------------------------------
				else:

					returning = true


		# ----------------------------------------------
		# FORCED RETURN TIMER
		# ----------------------------------------------
		if timer >= outward_time:

			returning = true


	# ==================================================
	# RETURN PHASE
	# ==================================================
	else:

		var return_dir = (
			thrower.global_position - global_position
		).normalized()

		return_dir.y = 0.0


		# Smooth return steering
		velocity = velocity.lerp(
			return_dir * return_speed,
			4.0 * delta
		)


		# ----------------------------------------------
		# NO WALL COLLISION DURING RETURN
		# ----------------------------------------------
		global_position += velocity * delta


		# ----------------------------------------------
		# RETURN COMPLETE
		# ----------------------------------------------
		if global_position.distance_to(
			thrower.global_position
		) < 1.5:

			queue_free()


	# ==================================================
	# SPIN VISUAL
	# ==================================================
	rotate_y(spin_speed * delta)
