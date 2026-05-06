extends Node3D

@export var normal_length: float = 10.0
@export var pan_length: float = 12.0
@export var normal_rotation_x: float = -45.0  
@export var pan_rotation_x: float = -55.0 
@export var zoom_speed: float = 1.0


# Camera rotation
@export var rotation_speed: float = 10.0  # lerp speed for snapping
@export var mouse_offset_strength: float = 2.0  # how far camera leans toward mouse
@export var mouse_offset_speed: float = 5.0     # how fast it'll lerp to offset

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var player: Node = null

var shake_strength: float = 0.0
var shake_fade: float = 12.0

# Camera rotation state
var target_rotation_y: float = 0.0
var current_mouse_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	Events.screen_shake.connect(_on_screen_shake)

func _on_screen_shake(duration: float, intensity: float) -> void:
	shake_strength = intensity
	shake_fade = 1.0 / duration

func _input(event: InputEvent) -> void:
	# Rotate camera 90 degrees with Q and E
	if event.is_action_pressed("cam_rotate_left"):
		target_rotation_y += PI / 2.0
	if event.is_action_pressed("cam_rotate_right"):
		target_rotation_y -= PI / 2.0


func _process(delta: float) -> void:
	if not player:
		return

	# Smoothly lerp camera Y rotation toward target
	rotation.y = lerp_angle(rotation.y, target_rotation_y, rotation_speed * delta)

	# Mouse offset - shift camera position toward where mouse is on screen
	var viewport := get_viewport()
	var viewport_size := viewport.get_visible_rect().size
	var mouse_pos := viewport.get_mouse_position()

	# Normalize mouse to -1..1 from center of screen
	var mouse_normalized := (mouse_pos / viewport_size) * 2.0 - Vector2.ONE

	# Build offset in world space relative to camera rotation
	var offset_local := Vector3(mouse_normalized.x, 0.0, mouse_normalized.y) * mouse_offset_strength
	var offset_world := Vector3(
		offset_local.x * cos(rotation.y) + offset_local.z * sin(rotation.y),
		0.0,
		-offset_local.x * sin(rotation.y) + offset_local.z * cos(rotation.y)
	)

	current_mouse_offset = current_mouse_offset.lerp(offset_world, mouse_offset_speed * delta)

	global_position = player.global_position + current_mouse_offset

	# Screen shake (offset, not position overwrite)
	var shake_offset = Vector3.ZERO

	if shake_strength > 0:
		shake_offset.x = randf_range(-1, 1) * shake_strength
		shake_offset.y = randf_range(-1, 1) * shake_strength
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)

	spring_arm.position = shake_offset

func zoom_out() -> void:
	print(self, "zoomed out")
	var tween := create_tween().set_parallel(true)
	tween.tween_property(spring_arm, "spring_length", pan_length, zoom_speed)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(spring_arm, "rotation_degrees:x", pan_rotation_x, zoom_speed)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)

func zoom_in() -> void:
	print(self, "zoomed in")
	var tween := create_tween().set_parallel(true)
	tween.tween_property(spring_arm, "spring_length", normal_length, zoom_speed)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(spring_arm, "rotation_degrees:x", normal_rotation_x, zoom_speed)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_CUBIC)
