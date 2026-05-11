class_name BossAnimController
extends Node3D

## AUDIO
@export var attack_sounds: Array[AudioStream]

## ANIMATION
@onready var eyes = $"../ShieldBoss/Armature/Shield2/Eye"
@onready var closed_eyes = $"../ShieldBoss/Armature/Shield2/ClosedEye"
@onready var animation: AnimationPlayer = $"../ShieldBoss/AnimationPlayer"
var animations = ["Attack", "Enter", "EnterIdle", "Hit", "Idle"]

## SIGNALS — used by boss.gd to react to animation events
signal fire_bullets       # fired from Call Method track in Attack & Enter animations
signal attack_finished    # fired when Attack animation ends for resuming movement

func _ready() -> void:
	animation.animation_finished.connect(_on_animation_player_animation_finished)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# Return to idle
	if anim_name in ["Attack", "Hit"]:
		attack_finished.emit()
		play_idle()
	# Enter to EnterIdle to Idle
	elif anim_name == "Enter":
		play_enter_idle()
	elif anim_name == "EnterIdle":
		play_idle()

# Called by Call Method track in the Attack & Enter animations
func _fire_bullets_callback() -> void:
	fire_bullets.emit()

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
	animation.play("Enter")

func play_enter_idle() -> void:
	animation.play("EnterIdle")
#endregion PLAY HELPERS
