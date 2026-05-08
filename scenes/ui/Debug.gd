class_name Debug
extends Control

@onready var key_status: Panel = $KeyStatus

func _ready() -> void:
	if OS.is_debug_build(): return
	visible = false

var pressed_color := Color("ff6666")
var normal_color := Color("ffffff")

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		
		var key_name := event.as_text()
		
		if key_name in ["W", "A", "S", "D", "Space", "Shift"]:
			
			var key_node = key_status.get_node_or_null(key_name)
			
			if key_node:
				if event.pressed:
					key_node.modulate = pressed_color
				else:
					key_node.modulate = normal_color
	
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
