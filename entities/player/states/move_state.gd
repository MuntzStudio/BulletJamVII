extends LimboState

var player: CharacterBody3D

func _enter() -> void:
	player = agent as CharacterBody3D

func _update(_delta: float) -> void:
	var dir = player.get_input_dir()
	if dir == Vector3.ZERO:
		dispatch(&"move_stopped")
		return
	player.velocity.x = dir.x * player.SPEED
	player.velocity.z = dir.z * player.SPEED
	if Input.is_action_just_pressed("dodge"):
		dispatch(&"dodge_started")
