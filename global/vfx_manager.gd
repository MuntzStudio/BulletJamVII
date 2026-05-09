## VFXManager - Autoload Singleton
extends Node

func spawn(scene: PackedScene, emitter: Node3D, attached: bool = true) -> void:
	if not is_inside_tree():
		return
	var vfx = scene.instantiate()
	if attached:
		emitter.add_child(vfx)
		vfx.transform = Transform3D.IDENTITY
	else:
		get_tree().current_scene.add_child(vfx)
		vfx.global_transform = emitter.global_transform

func hitstop(duration: float = 0.1, scale: float = 0.3) -> void:
	Engine.time_scale = scale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
