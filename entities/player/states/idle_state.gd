extends LimboState

var player: CharacterBody3D

func _enter() -> void:
	player = agent as CharacterBody3D

func _update(_delta: float) -> void:
	player.velocity.x = 0.0
	player.velocity.z = 0.0
	if player.get_input_dir() != Vector3.ZERO:
		dispatch(&"move_started")
	if Input.is_action_just_pressed("dodge") and player.dodge_cooldown_timer <= 0.0:
		dispatch(&"dodge_started")
