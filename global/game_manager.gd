# GameManager — Autoload Singleton
extends Node

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
