extends Node3D

@export var bullet_scene: PackedScene
@export var fire_rate := 1.0       # bullets per second
@export var bullet_count := 1      # per burst
@export var spread_angle := 30.0   # degrees spread for multi-shot

var _timer := 0.0
var _active := false

func _process(delta):
	if not _active:
		return
	_timer += delta
	if _timer >= 1.0 / fire_rate:
		_timer = 0.0
		fire()

func set_active(active: bool) -> void:
	_active = active
	_timer = 0.0

func fire():
	for i in bullet_count:
		var bullet = bullet_scene.instantiate()
		var dir = _get_direction(i)
		dir.y = 0.0
		bullet.direction = dir.normalized()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		bullet.launch(bullet.direction)
		print("spawn global_pos: ", global_position)

func _get_direction(index: int) -> Vector3:
	if bullet_count == 1:
		return global_transform.basis.z
	
	# spread evenly across spread_angle
	var half = spread_angle / 2.0
	var step = spread_angle / (bullet_count - 1)
	var angle = deg_to_rad(-half + step * index)
	
	var forward = - global_transform.basis.z
	return forward.rotated(Vector3.UP, angle).normalized()
