class_name MeleeEnemy
extends CharacterBody3D

const GRAVITY := 9.8
@export var friction: float = 0.15
@export var acceleration: float = 0.2
@export var max_health := 50.0

var health := max_health
var knockback := Vector3.ZERO

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var hurtbox: Hurtbox = $Hurtbox

func _ready() -> void:
	hurtbox.damage_taken.connect(_on_damage_taken)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	# Decay knockback
	knockback = knockback.lerp(Vector3.ZERO, 10.0 * delta)
	
	# Apply friction to movement only
	velocity.x = lerpf(velocity.x, 0.0, friction)
	velocity.z = lerpf(velocity.z, 0.0, friction)
	
	# Knockback after friction
	velocity.x += knockback.x
	velocity.z += knockback.z
	
	move_and_slide()

func _on_damage_taken(hitbox: Hitbox) -> void:
	health -= hitbox.damage

	var knock_dir = (global_position - hitbox.global_position).normalized()
	knock_dir.y = 0.0
	knockback = knock_dir * hitbox.knockback_force * hurtbox.knockback_multiplier

	if health <= 0.0:
		_die()

func _die() -> void:
	queue_free()  # replace with death animation later

func move(desired_velocity: Vector3) -> void:
	velocity.x = lerpf(velocity.x, desired_velocity.x, acceleration)
	velocity.z = lerpf(velocity.z, desired_velocity.z, acceleration)

func apply_friction() -> void:
	velocity.x = lerpf(velocity.x, 0.0, friction)
	velocity.z = lerpf(velocity.z, 0.0, friction)
