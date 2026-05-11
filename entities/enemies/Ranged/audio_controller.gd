extends Node3D

@export var bullet_sfx: Array[AudioStream] = []
@export var boomerang_sfx: Array[AudioStream] = []
@export_range(-20.0, 60.0) var audio_volume : float = 0.0

func play_boomerang():
	if !boomerang_sfx.is_empty():
		Audio.play_sound_3d(
		boomerang_sfx.pick_random(),
		global_position,
		audio_volume
		)

func play_bullet():
	if !bullet_sfx.is_empty():
		Audio.play_sound_3d(
		bullet_sfx.pick_random(),
		global_position,
		audio_volume
		)
