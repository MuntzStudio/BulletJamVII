@tool
extends Area3D

var dialogs = [
	"You fell off bozo!",
	"Skill issue lol",
	"Try again... brodda!",
	"Bro really said \"is there fall damage?\""
]

func _ready() -> void:
	randomize()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		await get_tree().create_timer(1.5).timeout
		body.queue_free()
		### TODO: fix this later to give points to player
	
	elif body.is_in_group("player"):
		var random_text = dialogs.pick_random()
		print(random_text)
		await get_tree().create_timer(1.5).timeout
		get_tree().reload_current_scene()
