# Audio Controller
extends Node

@export var dodge_sounds: Array[AudioStream] = []
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
