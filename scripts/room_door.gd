class_name Door
extends Node3D

@onready var DoorCollider: CollisionShape3D = $StaticBody3D/CollisionShape3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
var _locked: bool = false

func _ready() -> void:
	DoorCollider.disabled = true
	anim_player.animation_finished.connect(_on_animation_player_animation_finished)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "Open"):
		DoorCollider.disabled = true
	if (anim_name == "Close"):
		DoorCollider.disabled = false


func lock() -> void:
	_locked = true
	anim_player.play("Close")

func unlock() -> void:
	_locked = false
	anim_player.play("Open")
