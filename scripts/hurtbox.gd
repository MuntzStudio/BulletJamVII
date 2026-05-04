@tool
class_name Hurtbox extends Area3D

signal damage_taken(hitbox)

@export var mesh: MeshInstance3D 
@export var audio : AudioStream
@export var hit_vfx: PackedScene               # which vfx to spawn on hit
@export var hit_color: Color = Color.WHITE     # flash color
@export var flash_duration: float = 0.1
@export var knockback_multiplier: float = 1.0  # enemies can resist knockback

func  _ready() -> void:
	monitoring = false

func take_damage(hitbox: Hitbox) -> void:
	damage_taken.emit(hitbox)   # owner gets full hitbox data
	if audio:
		AudioManager.play_spatial_sound(audio, global_position)
	
	if hit_vfx:
		VFX.spawn(hit_vfx, self)
	_flash_color()

func make_invulnerable(duration : float = 1.0)-> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(duration).timeout
	process_mode = Node.PROCESS_MODE_INHERIT
	pass

func _flash_color() -> void:
	var mat: StandardMaterial3D = mesh.get_active_material(0).duplicate()
	mat.albedo_color = hit_color
	mesh.set_surface_override_material(0, mat)
	
	var timer := get_tree().create_timer(flash_duration, true, false, true)
	timer.timeout.connect(_on_flash_done)

func _on_flash_done() -> void:
	mesh.set_surface_override_material(0, null)
