class_name BossAnimController
extends Node3D

## AUDIO
@export var attack_sounds: Array[AudioStream]

## ANIMATION
@onready var eyes = get_node_or_null("Armature/Shield2/Eye")
@onready var closed_eyes = get_node_or_null("Armature/Shield2/ClosedEye")
@onready var animation: AnimationPlayer = $AnimationPlayer
var animations = ["Attack", "Enter", "EnterIdle", "Hit", "Idle"]

func _ready() -> void:
	animation.animation_finished.connect(_on_animation_player_animation_finished)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# Return to idle
	if anim_name in ["Attack", "Hit", "Enter"]:
		play_idle()

#region PLAY HELPERS
func play_attack() -> void:
	animation.play("Attack")
	if attack_sounds:
		Audio.play_sound_3d(attack_sounds.pick_random(), global_position)

func play_hit() -> void:
	# Only hit if not attacking
	if animation.current_animation != "Attack":
		animation.play("Hit")

func play_idle() -> void:
	animation.play("Idle")

func play_enter() -> void:
	# TODO Play intro then to EnterIdle
	animation.play("Enter")

func play_enter_idle() -> void:
	animation.play("EnterIdle")
#endregion PLAY HELPERS
