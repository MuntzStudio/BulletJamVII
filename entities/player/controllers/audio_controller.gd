# Audio Controller
extends Node3D


@export var dodge_sounds: Array[AudioStream] = []
@export var shoot_sounds: Array[AudioStream] = []
@export var respawn_sound: AudioStream
@onready var footstep_player: AudioStreamPlayer3D = $"../BulletBoy/Armature/Skeleton3D/Shoes/FootstepPlayer"

func _ready() -> void:
	footstep_player.finished.connect(_on_footstep_finished)

func _on_footstep_finished() -> void:
	if footstep_player.stream != null:
		footstep_player.play(randf_range(0.0, footstep_player.stream.get_length()))

func play_walk() -> void:
	if footstep_player.playing: return
	footstep_player.play(randf_range(0.0, footstep_player.stream.get_length()))

func stop_walk() -> void:
	footstep_player.stop()

func play_respawn() -> void:
	Audio.play_sound_3d(respawn_sound,global_position)
	pass

func play_dodge() -> void:
	if dodge_sounds.is_empty():
		return
		
	Audio.play_sound_3d(
		dodge_sounds.pick_random(),
		global_position
	)

func play_shoot() -> void:
	if shoot_sounds.is_empty():
		return
		
	Audio.play_sound_3d(
		shoot_sounds.pick_random(),
		self.global_position
	)
