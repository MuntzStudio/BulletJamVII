@tool
extends Area3D

@export var label: Label
@export var pivot : Node3D

var dialogs = [
	"You fell off bozo!",
	"Skill issue lol",
	"Try again... or not!",
	"There's fall damage.. isnt't that shocking!!",
	"Keep trying.. You still might not win."
]

func _ready() -> void:
	randomize()
	if label:
		label.hide()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		await get_tree().create_timer(1.5).timeout
		body.queue_free()
		# TODO: give points to player maybe
	
	elif body.is_in_group("player"):
		if body:
			pivot.stop_following()
			body.take_chip_damage(1)
			var random_text = dialogs.pick_random()
			label.text = random_text
			await get_tree().create_timer(1.0).timeout
			label.show()
			await get_tree().create_timer(1.5).timeout
			body.respawn()
			label.hide()
