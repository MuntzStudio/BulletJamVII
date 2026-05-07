# Animation Controller
extends Node

@export var player: Player 
@export var dodge_state: LimboState
@export var anim_tree: AnimationTree 
@onready var loco_sm: AnimationNodeStateMachinePlayback = anim_tree["parameters/Loco_sm/playback"]
@onready var bullet_boy: Node3D = $"../BulletBoy"
var idle_timer := 0.0
var idle_threshold := 0.0
var current_blend := Vector2.ZERO
var is_dodging := false
var shoot_tween: Tween


func _ready() -> void:
	player.shot_fired.connect(_on_shot_fired)
	player.hit_taken.connect(_on_hit_taken)
	dodge_state.dodge_started.connect(_on_dodge_started)
	dodge_state.dodge_finished.connect(_on_dodge_finished)

func _process(delta):
	_update_blend_position()
	_tick_idle(delta)

func _tick_idle(delta: float) -> void:
	if player.velocity.length() > 0.1:
		idle_timer = 0.0
		idle_threshold = randf_range(8.0, 10.0)
		return
	if anim_tree["parameters/OneShot/active"]:
		idle_timer = 0.0
		return
	idle_timer += delta
	if idle_timer > idle_threshold:
		idle_timer = 0.0
		idle_threshold = randf_range(8.0, 10.0)
		loco_sm.travel("Idle2")

func _update_blend_position() -> void:
	if is_dodging:
		return
	var local_vel = player.global_transform.basis.inverse() * player.velocity
	var target_blend = Vector2(local_vel.x, local_vel.z) / player.current_speed
	target_blend = target_blend.clamp(Vector2(-1, -1), Vector2(1, 1))
	current_blend = current_blend.lerp(target_blend, 10.0 * get_process_delta_time())
	anim_tree["parameters/Loco_sm/MoveState/blend_position"] = current_blend
	
	if player.velocity.length() > 0.1:
		loco_sm.travel("MoveState")
	else:
		loco_sm.travel("Idle1")


func _on_dodge_started() -> void:
	bullet_boy._close_eyes()
	is_dodging = true
	loco_sm.travel("Dodge")
	anim_tree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	anim_tree["parameters/Blend_Hit/blend_amount"] = 0.0

func _on_dodge_finished() -> void:
	bullet_boy._open_eyes()
	is_dodging = false
	loco_sm.travel("Idle1")

func _on_shot_fired() -> void:
	bullet_boy._close_eyes()
	anim_tree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	await get_tree().create_timer(0.4).timeout
	bullet_boy._open_eyes()

func _on_hit_taken() -> void:
	bullet_boy._close_eyes()
	anim_tree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	anim_tree["parameters/Blend_Hit/blend_amount"] = 1.0
	await get_tree().create_timer(0.3).timeout
	anim_tree["parameters/Blend_Hit/blend_amount"] = 0.0
	bullet_boy._open_eyes()
