extends Node3D

@export var enemies_to_spawn: int
@export var spawn_interval: float

@onready var spawn_point = $Marker3D
@onready var nav_region = owner.get_node("NavigationRegion3D")
@onready var enemies_spawned: int = 0
@onready var enemies = owner.get_node("Enemies")
@onready var timer = spawn_interval

var knife_enemy_jobber = load("res://entities/enemies/Melee/knife enemy jobber/knife_enemy_jobber.tscn")
var knife_enemy_lunger = load("res://entities/enemies/Melee/knife enemy lunger/knife_enemy_lunger.tscn")
var ranged_enemy_kite = load("res://entities/enemies/Ranged/ranged_enemy_kite.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for debugging
	enemies_to_spawn = 5
	spawn_interval = 5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if enemies_spawned < enemies_to_spawn:
		if timer <= 0:
			spawn_enemy()
			enemies_spawned += 1
			timer = spawn_interval
		else:
			timer -= delta
	else:
		#move to next level
		pass

func spawn_enemy():
	var enemy = get_random_enemy()
	enemies.add_child(enemy)
	enemy.global_position = spawn_point.global_position
	var target_position = NavigationServer3D.region_get_random_point(nav_region.get_region_rid(), 1, true)
	var direction = (target_position - enemy.global_position)
	print(target_position)
	launch_enemy(enemy, direction)
	
	

func get_random_enemy():
	match randi_range(0,2):
		0:
			return knife_enemy_lunger.instantiate()
		1:
			return knife_enemy_jobber.instantiate()
		2:
			return ranged_enemy_kite.instantiate()

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
		var position = spawn_point.global_position + v0 * t + 0.5 * Vector3(0, -g, 0)* pow(t, 2)
		enemy.global_position = position
		if position.y <= 0:
			break
		await get_tree().process_frame
		t += get_process_delta_time()
