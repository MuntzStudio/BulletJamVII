@tool
extends Area3D

@export var kill_label: Label 
@export var camera : Node3D

var dialogs = [
	"You fell... but not for long.",
	"One more try.",
	"That looked painful.",
	"The dungeon claims another victim.",
	"Careful where you step.",
	"Even the best miss a jump sometimes.",
	"Back to the action.",
	"Watch your footing next time.",
	"You were so close.",
	"Every fall is a lesson.",
	"The dungeon shows no mercy.",
	"Take a breath and try again.",
	"That trap got you good.",
	"Stay focused Bullet boy.",
	"Not the ending you hoped for.",
	"Somewhere, the enemies are celebrating.",
	"Respawning...",
	"That could have gone better.",
	"Don't give up yet.",
	"Another attempt begins."
]

var is_respawning : bool = false

func _ready() -> void:
	kill_label = get_tree().get_first_node_in_group("kill_label")
	camera = get_tree().get_first_node_in_group("camera")
	randomize()
	if kill_label:
		kill_label.hide()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		await get_tree().create_timer(1.5).timeout
		body.queue_free()
		# TODO: give points to player maybe

	elif body.is_in_group("player"):
		if body and not body.is_respawning:
			body.take_chip_damage(1)
			body.is_respawning = true
			camera.stop_following()
			body.collision.disabled = true
			kill_label.text = dialogs.pick_random()
			await get_tree().create_timer(0.5).timeout
			kill_label.show()
			await get_tree().create_timer(1.5).timeout
			await body.respawn()
			body.is_respawning = false
			kill_label.hide()
