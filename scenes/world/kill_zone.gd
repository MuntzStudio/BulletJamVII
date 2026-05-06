@tool
extends Area3D

@onready var label: Label = $"../DialogBox/Label"

var dialogs = [
	"You fell off bozo!",
	"Skill issue lol",
	"Try again... or not!",
	"There's fall damage.. isnt't that shocking!!",
	"Keep trying.. You still might not win."
]

func _ready() -> void:
	randomize()
	label.hide()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		await get_tree().create_timer(1.5).timeout
		body._die()
		# TODO: give points to player maybe
	
	elif body.is_in_group("player"):
		var random_text = dialogs.pick_random()
		label.text = random_text
		label.show()
		await get_tree().create_timer(1.5).timeout
		body._die()
		label.hide()
