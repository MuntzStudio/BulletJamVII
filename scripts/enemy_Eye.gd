extends Node3D

@onready var eyes = $Armature/Skeleton3D/Eyes
@onready var closed_eyes = $Armature/Skeleton3D/ClosedEyes

var blink_states = [
	"Hit",
	"Dodge",
	"Throw",
	"Fire",
	"Throw1",
	"Throw2"
]

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	update_eyes(anim_name)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	eyes.visible = true
	closed_eyes.visible = false

func update_eyes(anim_name: String) -> void:
	var blinking = anim_name in blink_states

	eyes.visible = not blinking
	closed_eyes.visible = blinking
