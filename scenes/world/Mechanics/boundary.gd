class_name Boundary
extends Area3D

func _ready() -> void:
	body_exited.connect(_on_body_exited)

func _on_body_exited(body):
	if body.has_method("on_out_of_bounds"):
		body.on_out_of_bounds(self)
