extends Control

@onready var resume: Button = %Resume
@onready var quit: Button = %Quit
@onready var player = get_tree().get_first_node_in_group("player")
@onready var hud    = get_parent().find_child("HeartHud")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	resume.pressed.connect(_on_resume_pressed)
	quit.pressed.connect(_on_quit_pressed)
	
	resume.focus_entered.connect(_on_resume_focus_entered)
	quit.focus_entered.connect(_on_quit_focus_entered)
	
	resume.mouse_entered.connect(_on_resume_mouse_entered)
	quit.mouse_entered.connect(_on_quit_mouse_entered)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()


func _toggle_pause() -> void:
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused
	hud.visible = !is_paused

func _on_resume_pressed() -> void:
	Audio.ui_select()
	_toggle_pause()


func _on_quit_pressed() -> void:
	Audio.ui_select()
	SaveManager.set_value("current_scene", get_tree().current_scene.scene_file_path)
	SaveManager.set_value("bullets", player.current_bullets)
	SaveManager.set_value("health", player.health)
	SaveManager.save_game()
	get_tree().quit()

func _on_resume_mouse_entered() -> void:
	Audio.ui_focus_change()

func _on_quit_mouse_entered() -> void:
	Audio.ui_focus_change()

func _on_resume_focus_entered() -> void:
	Audio.ui_focus_change()

func _on_quit_focus_entered() -> void:
	Audio.ui_focus_change()
