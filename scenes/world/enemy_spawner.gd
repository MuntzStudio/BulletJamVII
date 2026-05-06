@tool
extends StaticBody3D

@export var enemies_to_spawn: int = 5     # total budget
@export var maintain_count: int = 3         # keep this many alive at once
@export var spawn_interval: float = 1.0     # how fast it refills
@export var enemy_scenes: Array[PackedScene] = [] 

@onready var spawn_point = $Marker3D
@onready var nav_region = get_parent().get_node("NavigationRegion3D")
@onready var enemies = get_parent().get_node("Enemies")
@onready var timer: Timer = $Timer

var enemies_spawned: int = 0

func _ready() -> void:
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_timer_timeout)

func activate() -> void:
	enemies_spawned = 0
	timer.start()

func _on_timer_timeout() -> void:
	if enemies_spawned >= enemies_to_spawn:
		timer.stop()
		return
	
	# Count how many are currently alive
	var alive := enemies.get_child_count()
	var to_spawn := maintain_count - alive
	for i in to_spawn:
		if enemies_spawned >= enemies_to_spawn:
			break
		spawn_enemy()
		enemies_spawned += 1


func spawn_enemy():
	var enemy = get_random_enemy()
	if not enemy:
		return
	enemies.add_child(enemy)
	enemy.global_position = spawn_point.global_position
	var target_position = NavigationServer3D.region_get_random_point(nav_region.get_region_rid(), 1, true)
	var direction = (target_position - enemy.global_position)
	print(target_position)
	launch_enemy(enemy, direction)


func get_random_enemy():
	if enemy_scenes.is_empty():
		return null
	return enemy_scenes[randi() % enemy_scenes.size()].instantiate()


func launch_enemy(enemy, direction: Vector3):
	var t = 0.0
	var launch_angle = deg_to_rad(60)
	var dir = direction.normalized()
	var d = direction.length()
	var g = 9.8*2
	var speed = sqrt((d*g)/sin(2*launch_angle))
	# var launch_angle = .5 * arcsin((g*d)/speed)
	var v0 = Vector3(speed * cos(launch_angle) * dir.x, speed * sin(launch_angle), speed * cos(launch_angle) * dir.x)
	
	while true:
		var _position = spawn_point.global_position + v0 * t + 0.5 * Vector3(0, -g, 0)* pow(t, 2)
		enemy.global_position = _position
		if _position.y <= 0:
			break
		await get_tree().process_frame
		t += get_process_delta_time()

func is_done() -> bool:
	return enemies_spawned >= enemies_to_spawn and enemies.get_child_count() == 0
