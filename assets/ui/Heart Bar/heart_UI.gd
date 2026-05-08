extends TextureRect

@export var full_texture: Texture2D
@export var half_texture: Texture2D
@export var empty_texture: Texture2D


func set_state(state: int) -> void:

	match state:

		2:
			texture = full_texture

		1:
			texture = half_texture

		0:
			texture = empty_texture
