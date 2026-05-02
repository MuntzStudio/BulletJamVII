extends Node3D

@export var normal_length: float = 3.0
@export var hidden_length: float = 5.0
@export var zoom_speed: float = 3.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var player: Node = null

var shake_strength: float = 0.0
var shake_fade: float = 6.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _on_screen_shake(intensity: float) -> void:
	shake_strength = intensity

func _process(delta: float) -> void:
	if not player:
		return
	
	global_position = player.global_position 

	# Screen shake (offset, not position overwrite)
	var shake_offset = Vector3.ZERO
	
	if shake_strength > 0:
		shake_offset.x = randf_range(-1, 1) * shake_strength
		shake_offset.y = randf_range(-1, 1) * shake_strength
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
	
	spring_arm.position = shake_offset
