@tool
class_name Hurtbox extends Area3D

signal damage_taken(hitbox)

@export var audio : AudioStream
@export var hit_vfx: PackedScene               # which vfx to spawn on hit
@export var hit_color: Color = Color.WHITE     # flash color
@export var knockback_multiplier: float = 1.0  # enemies can resist knockback

func  _ready() -> void:
	monitoring = false

func take_damage(hitbox: Hitbox) -> void:
	damage_taken.emit(hitbox)   # owner gets full hitbox data
	if audio:
		AudioManager.play_spatial_sound(audio, global_position)
	
	if hit_vfx:
		VFX.spawn(hit_vfx, self)

func make_invulnerable(duration : float = 1.0)-> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(duration).timeout
	process_mode = Node.PROCESS_MODE_INHERIT
	pass
