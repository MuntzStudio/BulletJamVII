extends Node3D


@export var start_scene : PackedScene
@export var credits_scene : PackedScene
@export var sound_track : AudioStream
@export var player_anim : AnimationPlayer

@onready var cutscene_anim: AnimationPlayer = $Scene/AnimationPlayer
@onready var timer: Timer = %Timer
@onready var start: Button = %Start
@onready var credits: Button = %Credits
@onready var quit: Button = %Quit
var has_focused := false

func _ready() -> void:
	start.pressed.connect(_on_start_pressed)
	credits.pressed.connect(_on_credits_pressed)
	quit.pressed.connect(_on_quit_pressed)
	
	start.focus_entered.connect(_on_start_focus_entered)
	credits.focus_entered.connect(_on_credits_focus_entered)
	quit.focus_entered.connect(_on_quit_focus_entered)
	
	start.mouse_entered.connect(_on_start_mouse_entered)
	credits.mouse_entered.connect(_on_credits_mouse_entered)
	quit.mouse_entered.connect(_on_quit_mouse_entered)
	
	play_track()
	
	#region ANIMATION
	player_anim.play("Idle1")
	timer.timeout.connect(_play_idle2)
	player_anim.animation_finished.connect(_on_animation_finished)

func _play_idle2() -> void:
	player_anim.play("Idle2")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Idle2":
		player_anim.play("Idle1")
		timer.wait_time = randf_range(6.0, 10.0)
		timer.start()
	#endregion ANIMATION

func play_track() -> void:
	Audio.fade_in_first_track(sound_track, -2.0)

func _on_start_pressed() -> void:
	Audio.ui_select()
	if SaveManager.has_save():
		SaveManager.load_game()
		var saved_scene = SaveManager.get_value("current_scene", start_scene.resource_path)
		LoadManager.load_scene(saved_scene)
	else:
		SaveManager.delete_save()
		cutscene_anim.play("start_scene")
		await cutscene_anim.animation_finished
		if start_scene:
			LoadManager.load_scene(start_scene.resource_path)
	pass

func _on_credits_pressed() -> void:
	Audio.ui_select()
	if credits_scene: 
		LoadManager.load_scene(credits_scene.resource_path)

func _on_quit_pressed() -> void:
	Audio.ui_select()
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if has_focused:
		return
	
	if event is InputEventKey and event.pressed:
		start.grab_focus()
		has_focused = true

func _on_start_focus_entered() -> void:
	Audio.ui_focus_change()

func _on_credits_focus_entered() -> void:
	Audio.ui_focus_change()

func _on_quit_focus_entered() -> void:
	Audio.ui_focus_change()

func _on_start_mouse_entered() -> void:
	Audio.ui_focus_change()

func _on_credits_mouse_entered() -> void:
	Audio.ui_focus_change()

func _on_quit_mouse_entered() -> void:
	Audio.ui_focus_change()
