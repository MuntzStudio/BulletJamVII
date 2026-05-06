class_name Boundary
extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		get_parent()._on_player_entered()

func _on_body_exited(body):
	if body.is_in_group("player"):
		get_parent()._on_player_exited()
	
	print("EXIT DETECTED: ", body.name)
	if body.has_method("on_out_of_bounds"):
		body.on_out_of_bounds(self)
