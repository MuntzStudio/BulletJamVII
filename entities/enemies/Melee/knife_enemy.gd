class_name MeleeEnemy
extends CharacterBody3D

const GRAVITY := 9.8
@export var friction: float = 0.15
@export var acceleration: float = 0.2

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	velocity.x = lerpf(velocity.x, 0.0, friction)
	velocity.z = lerpf(velocity.z, 0.0, friction)
	move_and_slide()

func move(desired_velocity: Vector3) -> void:
	
	# Lerp toward desired instead of snapping to it
	velocity.x = lerpf(velocity.x, desired_velocity.x, acceleration)
	velocity.z = lerpf(velocity.z, desired_velocity.z, acceleration)

func apply_friction() -> void:
	velocity.x = lerpf(velocity.x, 0.0, friction)
	velocity.z = lerpf(velocity.z, 0.0, friction)
