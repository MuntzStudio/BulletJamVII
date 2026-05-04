extends Area3D

func _on_body_exited(body):
	print("EXIT DETECTED: ", body.name)
	if body.has_method("on_out_of_bounds"):
		body.on_out_of_bounds(self)
