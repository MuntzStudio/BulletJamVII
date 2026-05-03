# VFXManager — Autoload Singleton
extends Node

func spawn(scene: PackedScene, emitter: Node3D) -> void:
	var vfx = scene.instantiate()
	emitter.add_child(vfx)
	vfx.global_transform.origin = emitter.global_transform.origin
