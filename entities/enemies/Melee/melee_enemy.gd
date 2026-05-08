class_name MeleeEnemy
extends CharacterBody3D

@export var friction: float = 0.15
@export var acceleration: float = 0.2
@export var max_health := 50.0
@export var death_vfx : PackedScene 

const GRAVITY := 9.8

var health: float
var knockback := Vector3.ZERO
var _is_dying: bool = false


@onready var bt_player: BTPlayer = $BTPlayer
@onready var health_bar: HealthBar = $HealthBar/SubViewport/Panel/HealthBar
@onready var anim_player: AnimationPlayer = find_child("AnimationPlayer")
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var hurtbox: Hurtbox = $Hurtbox

func _ready() -> void:
	health = max_health
	health_bar.init_health(max_health)
	hurtbox.damage_taken.connect(_on_damage_taken)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	
	# Apply friction to movement only
	velocity.x = lerpf(velocity.x, 0.0, friction)
	velocity.z = lerpf(velocity.z, 0.0, friction)
	
	move_and_slide()

func move(desired_velocity: Vector3) -> void:
	velocity.x = lerpf(velocity.x, desired_velocity.x, acceleration)
	velocity.z = lerpf(velocity.z, desired_velocity.z, acceleration)

func apply_friction() -> void:
	velocity.x = lerpf(velocity.x, 0.0, friction)
	velocity.z = lerpf(velocity.z, 0.0, friction)

func _on_damage_taken(hitbox: Hitbox) -> void:
	if _is_dying:
		return
	
	bt_player.blackboard.set_var(&"is_hit", true)
	
	health -= hitbox.damage
	health_bar._on_health_changed(health, max_health)
	VFX.hitstop(0.2, 0.3)

	var knock_dir = (global_position - hitbox.global_position).normalized()
	knock_dir.y = 0.0
	velocity.x = knock_dir.x * hitbox.knockback_force * hurtbox.knockback_multiplier
	velocity.z = knock_dir.z * hitbox.knockback_force * hurtbox.knockback_multiplier

	if health <= 0.0:
		_is_dying = true
		_die()

func _die() -> void:
	hurtbox.make_invulnerable()
	set_physics_process(false)
	bt_player.set_active(false)
	if health_bar:
		health_bar.hide()
	var hitbox = get_node_or_null("Hitbox")
	if hitbox:
		hitbox.set_active(false)
	if death_vfx:
		VFX.spawn(death_vfx, self)
	await _launch_goofy()
	queue_free()

func _launch_goofy() -> void:
	var rand_dir := Vector3(randf_range(-1.0, 1.0), 0.5, randf_range(-1.0, 1.0)).normalized()
	var launch_force := randf_range(10.0, 10.0)
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "global_position",
		global_position + rand_dir * launch_force, 1.0)
	tween.tween_property(self, "rotation",
		rotation + Vector3(randf_range(-5.0, 5.0), randf_range(-5.0, 5.0), randf_range(-5.0, 5.0)), 1.0)
	
	# Fade any mesh found in children
	for child in find_children("*", "MeshInstance3D", true):
		tween.tween_property(child, "transparency", 1.0, 1.0)
	
	await tween.finished
