extends CharacterBody3D

# =========================
# STATES
# =========================
enum BulletState {
	FLYING,
	FALLING,
	DROPPED
}

# =========================
# EXPORTS
# =========================
@export var speed: float = 25.0
@export var gravity: float = -35.0
@export var ground_y: float = 0.1

# Magnetic behaviour settings
@export var magnet_range: float = 3.0
@export var magnet_strength: float = 12.0

# =========================
# VARIABLES
# =========================
var state = BulletState.FLYING
var _hit : bool = false

# =========================
# NODE REFERENCES
# =========================
@onready var hitbox: Hitbox = $Hitbox
@onready var pickup_area: Area3D = $PickupArea


# =========================
# READY
# =========================
func _ready():
	pickup_area.monitoring = true  # needed for overlap queries

	# Prevent collision with player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		add_collision_exception_with(player)


# =========================
# PHYSICS LOOP
# =========================
func _physics_process(delta):
	#print("STATE: ", state)

	match state:
		BulletState.FLYING:
			_handle_flying(delta)

		BulletState.FALLING:
			_handle_falling(delta)

		BulletState.DROPPED:
			_handle_dropped(delta)


# =========================
# FLYING
# =========================
func _handle_flying(delta):

	velocity.y = 0.0

	var collision = move_and_collide(velocity * delta)

	if collision:
		_on_collision(collision)


# =========================
# COLLISION
# =========================
func _on_collision(collision: KinematicCollision3D):
	if _hit:
		return
	_hit = true
	var hit = collision.get_collider()
	global_position += collision.get_normal() * 0.3
	velocity = Vector3.ZERO
	state = BulletState.FALLING
	
	if hit.is_in_group("enemy"):
		hitbox.activate(0.05)


# =========================
# FALLING
# =========================
func _handle_falling(delta):

	velocity.y += gravity * delta
	move_and_slide()

	# Force drop after reaching near ground
	if global_position.y < 0.5:
		global_position.y = ground_y
		#print("FORCED DROP")
		_drop()


# =========================
# DROP
# =========================
func _drop():

	state = BulletState.DROPPED

	velocity = Vector3.ZERO

	# Disable enemy interaction
	hitbox.set_active(false)
	collision_mask = 1   # only world (or 0 if you want none)

	# Small squash effect
	scale *= 0.9
	await get_tree().create_timer(0.05).timeout
	scale *= 1.1


# =========================
# DROPPED (Pickup + Magnetic kinda behaviour)
# =========================
func _handle_dropped(delta):

	var player = get_tree().get_first_node_in_group("player")
	#print("PLAYER FOUND: ", player)
	
	if player:
		#print("DIST: ", global_position.distance_to(player.global_position))
		pass
	if not player:
		return

	var dist = global_position.distance_to(player.global_position)

	# Magnet pull
	if dist < magnet_range:
		var dir = (player.global_position - global_position).normalized()
		global_position += dir * magnet_strength * delta

	# Pickup check (manual)
	if dist < 1.2:
		player.collect_bullet(1)
		queue_free()

func on_out_of_bounds(boundary):

	# Direction from center to bullet
	var center = boundary.global_position
	var dir = (global_position - center).normalized()
	dir.y = 0

	# Move bullet slightly INSIDE the arena
	global_position -= dir * 10   # tweak distance if needed

	# Stop movement
	velocity = Vector3.ZERO

	# Force it to fall and become collectible
	state = BulletState.FALLING
