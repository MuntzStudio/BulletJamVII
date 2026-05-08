extends LimboState

signal dodge_started
signal dodge_finished

var dodge_height    : float = 6.0
var dodge_timer     : float = 0.0
var dodge_direction : Vector3 = Vector3.ZERO
var player: CharacterBody3D

func _enter() -> void:
	player = agent as CharacterBody3D
	dodge_started.emit()
	player.can_rotate_to_mouse= false
	dodge_timer     = player.DODGE_DURATION
	dodge_direction = player.get_input_dir()
	player.hurtbox.make_invulnerable(player.DODGE_DURATION)
	player.velocity.y = dodge_height
	if dodge_direction == Vector3.ZERO:
		dodge_direction = player.global_transform.basis.z

func _update(delta: float) -> void:
	dodge_timer -= delta
	player.velocity.x = dodge_direction.x * player.current_dodge_speed
	player.velocity.z = dodge_direction.z * player.current_dodge_speed
	if dodge_timer <= 0.0:
		dispatch(&"dodge_finished")
		player.can_rotate_to_mouse = true
		dodge_finished.emit()
