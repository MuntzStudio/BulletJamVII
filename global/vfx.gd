# VFXManager — Autoload Singleton
extends Node

func spawn(scene: PackedScene, emitter: Node3D) -> void:
	if not is_inside_tree():
		return
	var vfx = scene.instantiate()
	emitter.add_child(vfx)
	vfx.global_transform.origin = emitter.global_transform.origin


func hitstop(duration: float = 0.1, scale: float = 0.3) -> void:
	Engine.time_scale = scale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
