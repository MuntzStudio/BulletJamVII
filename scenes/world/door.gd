class_name Door
extends StaticBody3D

@export var open_position: Vector3 = Vector3(0, 4.5, 0)
@export var closed_position: Vector3 = Vector3(0, 1.5, 0)
@export var tween_duration: float = 0.4
@export var mesh: Node3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var _locked: bool = false
var _tween: Tween

func _ready() -> void:
	if mesh:
		mesh.position = open_position
	collision.disabled = true

func lock() -> void:
	_locked = true
	collision.disabled = false
	_animate_to(closed_position)

func unlock() -> void:
	collision.disabled = true
	_locked = false
	_animate_to(open_position)

func _animate_to(target: Vector3) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(mesh, "position", target, tween_duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
