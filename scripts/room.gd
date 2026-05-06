class_name Room
extends Node3D

signal room_cleared

@export var doors: Array[Door] = []
@export var enemy_group: StringName = &"enemy"
@onready var camera: Node3D = get_tree().get_first_node_in_group("camera")

var _active: bool = false
var _cleared: bool = false

func _ready() -> void:
	# Freeze all pre-placed enemies
	for enemy in get_children():
		if enemy.is_in_group("enemy"):
			enemy.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Keep check if all enemies are dead
	var timer := Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(_check_cleared)
	add_child(timer)

func _on_player_entered() -> void:
	if _active or _cleared:
		return
	camera.zoom_out()
	
	_active = true
	_lock_doors()
	
	for enemy in get_children():
		if enemy.is_in_group("enemy"):
			enemy.process_mode = Node.PROCESS_MODE_INHERIT
	
	# TODO spawner launches enemies


func _on_player_exited() -> void:
	if not _cleared:
		return  # room not cleared!!? no transition for you!
	camera.zoom_in()

func _check_cleared() -> void:
	if not _active:
		return
	var enemies := get_tree().get_nodes_in_group(enemy_group)
	# Filters only enemies that belong to this room
	var mine := enemies.filter(func(e): return e.get_parent() == self)
	if mine.size() == 0:
		_on_cleared()

func _on_cleared() -> void:
	_active = false
	_cleared = true
	_unlock_doors()
	room_cleared.emit()

func _lock_doors() -> void:
	for door in doors:
		if door:
			door.lock()

func _unlock_doors() -> void:
	for door in doors:
		if door:
			door.unlock()
