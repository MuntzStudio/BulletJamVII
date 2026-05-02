class_name Player
extends CharacterBody3D

#region CONSTANTS
const SPEED          := 7.0
const DODGE_SPEED    := 15.0
const DODGE_DURATION := 0.3
const GRAVITY        := -20.0
#endregion CONSTANTS

#region EXPORTS 
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.15
#endregion EXPORTS 

#region NODE REFS 
@onready var bullet_spawn: Marker3D = $Pivot/BulletSpawnPoint
@onready var hsm          : LimboHSM = $LimboHSM
#endregion NODE REFS 

#region STATES UNDER LIMBOHSM
@onready var state_idle  : LimboState = $LimboHSM/IdleState
@onready var state_move  : LimboState = $LimboHSM/MoveState
@onready var state_dodge : LimboState = $LimboHSM/DodgeState
#endregion STATES UNDER LIMBOHSM

#region VARIABLES
var fire_timer      : float = 0.0
#endregion VARIABLES

#region READY AND PROCESS
func _ready() -> void:
	_setup_hsm()

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
	
	# Shooting is global - works in any state
	_handle_shooting(delta)
	
	move_and_slide()
	_face_mouse()

#endregion LIFECYCLE

#region SHOOTING
func _handle_shooting(delta: float) -> void:
	fire_timer -= delta
	if Input.is_action_pressed("shoot") and fire_timer <= 0.0:
		fire_timer = fire_rate
		_shoot()

func _shoot() -> void:
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = bullet_spawn.global_position
	var dir := (_get_mouse_world_pos() - bullet_spawn.global_position).normalized()
	dir.y = 0.0
	bullet.direction = dir
#endregion SHOOTING

#region MOUSE AIMING
func _face_mouse() -> void:
	var dir := _get_mouse_world_pos() - global_position
	dir.y = 0.0
	if dir.length_squared() > 0.01:
		rotation.y = atan2(dir.x, dir.z)

func _get_mouse_world_pos() -> Vector3:
	var camera    := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_dir    := camera.project_ray_normal(mouse_pos)
	if abs(ray_dir.y) < 0.0001:
		return global_position
	var t := -ray_origin.y / ray_dir.y
	return ray_origin + ray_dir * t
#endregion MOUSE AIMING

#region HELPERS
func get_input_dir() -> Vector3:
	var input := Vector2(
		Input.get_axis("move_left",  "move_right"),
		Input.get_axis("move_front",    "move_back")
	)
	return Vector3(input.x, 0.0, input.y).normalized()
#endregion HELPERS
