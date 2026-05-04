extends LimboState

var dodge_timer     := 0.0
var dodge_direction := Vector3.ZERO
var player: CharacterBody3D

func _enter() -> void:
	player = agent as CharacterBody3D
	dodge_timer     = player.DODGE_DURATION
	dodge_direction = player.get_input_dir()
	if dodge_direction == Vector3.ZERO:
		dodge_direction = -player.global_transform.basis.z

func _update(delta: float) -> void:
	dodge_timer -= delta
	player.velocity.x = dodge_direction.x * player.current_dodge_speed
	player.velocity.z = dodge_direction.z * player.current_dodge_speed
	if dodge_timer <= 0.0:
		dispatch(&"dodge_finished")
