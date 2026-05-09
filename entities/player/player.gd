class_name Player
extends CharacterBody3D

#region CONSTANTS
const DODGE_COOLDOWN := 1.0
const BASE_SPEED := 7.0
const BASE_DODGE_SPEED := 15.0
const DODGE_DURATION := 0.5
const GRAVITY        := -20.0
#endregion CONSTANTS

#region SIGNALS
signal hit_taken
signal shot_fired
#endregion SIGNALS

#region EXPORTS 
@export var base_radius := 0.8
@export var base_height := 3.0
@export var bullet_scene: PackedScene
@export var max_health : int = 6
@export var fire_rate  : float = 0.2
@export var max_bullets: int = 8
@export var current_bullets: int = 6
#endregion EXPORTS 

#region NODE REFS 
@onready var bullet_spawn : Node3D = $BulletBoy/Armature/Skeleton3D/Nose/BulletSpawn
@onready var hsm          : LimboHSM = $LimboHSM
@onready var hurtbox      : Hurtbox = $Hurtbox
@onready var anim_controller: Node = $AnimController
@onready var pivot: Node3D = get_parent().get_node("SpringArmPivot")
@onready var audio_controller: Node = $AudioController
@onready var bullet_boy: Node3D = $BulletBoy
#endregion NODE REFS 

#region STATES UNDER LIMBOHSM
@onready var state_idle  : LimboState = $LimboHSM/IdleState
@onready var state_move  : LimboState = $LimboHSM/MoveState
@onready var state_dodge : LimboState = $LimboHSM/DodgeState
#endregion STATES UNDER LIMBOHSM

#region GAME VARIABLES / BOOlS
var dodge_cooldown_timer    : float = 0.0
var current_speed           : float = BASE_SPEED
var current_dodge_speed     : float= BASE_DODGE_SPEED
var waiting_for_mouse_input : bool = false
var last_safe_position      : Vector3
var knockback               : Vector3 = Vector3.ZERO
var health                  : int = max_health
var fire_timer              : float = 0.0
var can_rotate_to_mouse     : bool = true
#endregion VARIABLES

#region READY AND PROCESS
func _ready() -> void:
	# Loaded by SaveManager
	_on_load() 
	
	# On general
	hurtbox.damage_taken.connect(_on_damage_taken)
	last_safe_position = global_position
	_setup_hsm()
	_update_scaling()
	await get_tree().process_frame

	var hud = get_tree().get_first_node_in_group(
		"health_hud"
	)

	if hud:
		hud.update_hearts(health, max_health) 

func _on_load()-> void:
	current_bullets = SaveManager.get_value("bullets", max_bullets) as int
	bullet_boy.update_bullets(current_bullets)
	
	if current_bullets > 0:
		bullet_boy._scale_Boy(bullet_boy.bulletSize[current_bullets - 1])
	else:
		bullet_boy._scale_Boy(bullet_boy.bulletSize[0]) 

func _setup_hsm() -> void:
	# Transitions only 
	hsm.add_transition(state_idle,  state_move,  &"move_started")
	hsm.add_transition(state_move,  state_idle,  &"move_stopped")
	hsm.add_transition(state_idle,  state_dodge, &"dodge_started")
	hsm.add_transition(state_move,  state_dodge, &"dodge_started")
	hsm.add_transition(state_dodge, state_idle,  &"dodge_finished")
	
	hsm.initialize(self)
	hsm.set_active(true)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Floor check
	if is_on_floor():
		last_safe_position = global_position
	
	# Decay knockback
	knockback = knockback.lerp(Vector3.ZERO, 10.0 * delta)
	velocity.x += knockback.x
	velocity.z += knockback.z
	
	# Shooting is global - works in any state
	_handle_shooting(delta)
	
	# Dodge timer
	if dodge_cooldown_timer > 0.0:
		dodge_cooldown_timer -= delta
	
	move_and_slide()
	_face_mouse()

#endregion LIFECYCLE

#region DAMAGE/ DEATH/ RESPAWN HANDLING
func _on_damage_taken(hitbox: Hitbox) -> void:
	health -= hitbox.damage
	
	var hud = get_tree().get_first_node_in_group(
	"health_hud"
	)

	if hud:
		hud.update_hearts(health, max_health)
	
	hit_taken.emit()
	
	# Knockback
	var knock_dir = (global_position - hitbox.global_position).normalized()
	knock_dir.y = 0.0
	knockback = knock_dir * hitbox.knockback_force
	
	# Invulnerability frames so bullets don't all hit at once
	hurtbox.make_invulnerable(0.5)
	
	# Screenshake via Events autoload
	Events.screen_shake.emit(0.2, 0.2)
	VFX.hitstop(0.3, 0.3)
	
	if health <= 0.0:
		_die()

func take_chip_damage(amount: int) -> void:
	health -= amount
	
	var hud = get_tree().get_first_node_in_group(
	"health_hud"
	)

	if hud:
		hud.update_hearts(health, max_health)
	
	hit_taken.emit()
	hurtbox.make_invulnerable(0.5)
	Events.screen_shake.emit(0.1, 0.1)  # lighter shake for chip
	if health <= 0.0:
		_die()

func respawn():
	print(health)
	waiting_for_mouse_input = true
	can_rotate_to_mouse = false
	set_physics_process(false)
	global_position = last_safe_position
	velocity = Vector3.ZERO
	pivot.is_returning = true 
	await get_tree().physics_frame
	set_physics_process(true)

func _die() -> void:
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)  
	hurtbox.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	await get_tree().process_frame  
	SaveManager.delete_save()
	get_tree().reload_current_scene() # TODO replace with GAMEOVER
#endregion DAMAGE HANDLING

#region SHOOTING / SCALING
func _handle_shooting(delta: float) -> void:
	fire_timer -= delta
	if Input.is_action_pressed("shoot") and fire_timer <= 0.0:
		fire_timer = fire_rate
		_shoot()

func _shoot():
	if current_bullets <= 0:
		return
	shot_fired.emit()
	await get_tree().create_timer(0.1).timeout  
	
	current_bullets -= 1
	_update_scaling()
	
	var dir := (_get_mouse_world_pos() - global_position)
	dir.y = 0.0
	dir = dir.normalized()
	
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = bullet_spawn.global_position
	bullet.velocity = dir * 25.0
	bullet.look_at(bullet.global_position + dir, Vector3.UP)

func collect_bullet(amount: int):
	current_bullets = clamp(current_bullets + amount, 0, max_bullets)
	_update_scaling()
	bullet_boy.update_bullets(current_bullets)

func _update_scaling():
	var speed_multiplier = lerp(1.5, 1.0, float(current_bullets) / float(max_bullets))
	current_speed = BASE_SPEED * speed_multiplier
	current_dodge_speed = BASE_DODGE_SPEED * speed_multiplier
	bullet_boy.update_bullets(current_bullets)
	if current_bullets > 0:
		var s = bullet_boy.bulletSize[current_bullets-1]
		bullet_boy._scale_Boy(s)
		var shape : CapsuleShape3D = hurtbox.get_node("CollisionShape3D").shape
		shape.radius = base_radius * s
		shape.height = base_height * (1.0 + ((s - 1.0) * 0.25))
	pass
#endregion SHOOTING

#region MOUSE AIMING
func _face_mouse() -> void:
	if waiting_for_mouse_input:
		return
	if not can_rotate_to_mouse:
		return
	
	var dir := _get_mouse_world_pos() - global_position
	dir.y = 0.0
	if dir.length_squared() > 0.01:
		var target_rotation := atan2(dir.x, dir.z)
		rotation.y = lerp_angle(
			rotation.y,
			target_rotation,
			12.0 * get_process_delta_time()
		)

func _get_mouse_world_pos() -> Vector3:
	var camera := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir := camera.project_ray_normal(mouse_pos)
	if abs(ray_dir.y) < 0.0001:
		return global_position
	var t := (global_position.y - ray_origin.y) / ray_dir.y  # use player's y not 0
	return ray_origin + ray_dir * t
#endregion MOUSE AIMING

#region HELPERS
func get_input_dir() -> Vector3:
	var input := Vector2(
		Input.get_axis("move_left",  "move_right"),
		Input.get_axis("move_front",    "move_back")
	)
	var dir := Vector3(input.x, 0.0, input.y).normalized()
	
	# Rotate input relative to SpringArmPivot's Y rotation
	if pivot:
		var cam_y : float = pivot.target_rotation_y
		dir = Vector3(
			dir.x * cos(cam_y) + dir.z * sin(cam_y),
			0.0,
			-dir.x * sin(cam_y) + dir.z * cos(cam_y)
		)
	
	return dir
#endregion HELPERS

#region INPUT NORMAL / DEBUG
func _input(event: InputEvent) -> void:
	if waiting_for_mouse_input and event is InputEventMouseMotion:
		waiting_for_mouse_input = false
		can_rotate_to_mouse = true

	if not OS.is_debug_build():
		return
	
	if event.is_action_pressed("ui_cancel") and not event.echo:
		hurtbox.is_invulnerable = !hurtbox.is_invulnerable
		print("HULK SMASH? : ", hurtbox.is_invulnerable)
#endregion INPUT DEBUG
