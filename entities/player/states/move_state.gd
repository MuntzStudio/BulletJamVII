extends LimboState

var player: CharacterBody3D
@onready var audio_controller: Node = $"../../AudioController"

func _enter() -> void:
	player = agent as CharacterBody3D

func _update(_delta: float) -> void:
	var dir = player.get_input_dir()
	if dir == Vector3.ZERO:
		audio_controller.stop_walk()
		dispatch(&"move_stopped")
		return
	player.velocity.x = dir.x * player.current_speed
	player.velocity.z = dir.z * player.current_speed
	audio_controller.play_walk()
	if Input.is_action_just_pressed("dodge") and player.dodge_cooldown_timer <= 0.0:
		audio_controller.stop_walk()
		dispatch(&"dodge_started")
