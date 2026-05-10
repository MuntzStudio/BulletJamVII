## GameManager - Autoload Singleton
extends Node

var enemies: Array = []

func _ready() -> void:
	# FOR RELEASE BUILD
	release_build()
	get_tree().set_auto_accept_quit(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			SaveManager.set_value("current_scene", get_tree().current_scene.scene_file_path)
			SaveManager.set_value("bullets", player.current_bullets)
			SaveManager.set_value("health", player.health)
			SaveManager.save_game()
		get_tree().quit()

#region RELEASE BUILD
func release_build() -> void:
	if OS.is_debug_build(): return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
#endregion RELEASE BUILD
