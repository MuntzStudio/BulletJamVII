# GameManager — Autoload Singleton
extends Node

var enemies: Array = []

func _ready() -> void:
	# FOR RELEASE BUILD
	release_build()

#region RELEASE BUILD
func release_build() -> void:
	if OS.is_debug_build(): return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
#endregion RELEASE BUILD
