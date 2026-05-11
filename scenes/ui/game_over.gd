extends Control
const restart_scene = "res://scenes/ui/main_menu.tscn"
@onready var restart: Button = %Restart
@onready var quit: Button = %Quit
@onready var reload: Button = %Reload
@export var gameover_song : AudioStream

func _ready() -> void:
	Audio.play_ambience(gameover_song,-1.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	restart.pressed.connect(_on_restart_pressed)
	reload.pressed.connect(_on_reload_pressed)
	quit.pressed.connect(_on_quit_pressed)
	
	restart.focus_entered.connect(_on_restart_focus_entered)
	quit.focus_entered.connect(_on_quit_focus_entered)
	
	restart.mouse_entered.connect(_on_restart_mouse_entered)
	quit.mouse_entered.connect(_on_quit_mouse_entered)

func _on_restart_pressed() -> void:
	Audio.ui_select()
	get_tree().paused = false
	SaveManager.delete_save()
	if restart_scene:
		LoadManager.load_scene(restart_scene)
	else:
		print("restart_scene is null!")

func _on_reload_pressed() -> void:
	Audio.ui_select()
	get_tree().paused = false
	if SaveManager.has_save():
		SaveManager.load_game()
		var saved_scene = SaveManager.get_value("current_scene", restart_scene)
		LoadManager.load_scene(saved_scene)
	else:
		LoadManager.load_scene(restart_scene)

func _on_quit_pressed() -> void:
	Audio.ui_select()
	get_tree().quit()

func _on_restart_mouse_entered() -> void:
	Audio.ui_focus_change()

func _on_quit_mouse_entered() -> void:
	Audio.ui_focus_change()

func _on_restart_focus_entered() -> void:
	Audio.ui_focus_change()

func _on_quit_focus_entered() -> void:
	Audio.ui_focus_change()
