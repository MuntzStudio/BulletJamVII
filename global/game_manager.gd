# GameManager — Autoload Singleton
extends Node

var enemies: Array = []



func _ready() -> void:
	# FOR RELEASE BUILD
	if not OS.is_debug_build():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


func _process(_delta: float) -> void:
	# FOR DEBUG
	if OS.is_debug_build():
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()

func register_enemy(enemy: Node) -> void:
	enemies.append(enemy)

func _input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				toggle_enemy_by_index(0)
			KEY_2:
				toggle_enemy_by_index(1)
			KEY_3:
				toggle_enemy_by_index(2)
			KEY_4:
				toggle_enemy_by_index(3)


func toggle_enemy_by_index(i: int) -> void:
	if i >= enemies.size():
		print("Enemy not registered at index:", i)
		return
	
	var enemy = enemies[i]
	if not is_instance_valid(enemy):
		return
	
	var new_state = not enemy.visible
	
	enemy.visible = new_state
	enemy.process_mode = Node.PROCESS_MODE_INHERIT if new_state else Node.PROCESS_MODE_DISABLED
