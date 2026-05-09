extends Node3D


@export var start_scene : PackedScene
@export var credits_scene : PackedScene
@export var sound_track : AudioStream

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

func play_track() -> void:
	Audio.fade_in_first_track(sound_track, -2.0)

func _on_start_pressed() -> void:
	Audio.ui_select()
	LoadManager.load_scene(start_scene.resource_path)

func _on_credits_pressed() -> void:
	Audio.ui_select()
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
