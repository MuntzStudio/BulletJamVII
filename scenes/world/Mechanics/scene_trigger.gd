# SceneTrigger: Can work with Area3D (or Area2D)
extends Area3D

@export var next_scene: PackedScene = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	# Save current state before leaving
	SaveManager.set_value("current_scene", next_scene)
	SaveManager.set_value("bullets", body.current_bullets)
	
	LoadManager.load_scene(next_scene.resource_path)
