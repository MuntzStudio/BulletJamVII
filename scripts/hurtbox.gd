class_name Hurtbox extends Area3D

signal damage_taken(hitbox)

@export var mesh: MeshInstance3D 
@export var audio : AudioStream
@export var hit_vfx: PackedScene               # which vfx to spawn on hit
@export var hit_color: Color = Color.WHITE     # flash color
@export var flash_duration: float = 0.1
@export var knockback_multiplier: float = 1.0  # enemies can resist knockback
@export var is_invulnerable := false
@export var tick_rate: float = 0.5  # how often recurring damage applies

var _overlapping_hitboxes: Array = []
var _tick_timer: float = 0.0

func  _ready() -> void:
	monitoring = false

func _process(delta: float) -> void:
	if _overlapping_hitboxes.is_empty():
		return
	_tick_timer += delta
	if _tick_timer >= tick_rate:
		_tick_timer = 0.0
		for hitbox in _overlapping_hitboxes:
			take_damage(hitbox)

func _on_area_entered(area: Area3D) -> void:
	if area is Hitbox:
		_overlapping_hitboxes.append(area)
		take_damage(area) 

func _on_area_exited(area: Area3D) -> void:
	if area is Hitbox:
		_overlapping_hitboxes.erase(area)

func take_damage(hitbox: Hitbox) -> void:
	if is_invulnerable:
		return
	damage_taken.emit(hitbox)   # owner gets full hitbox data
	if audio:
		AudioManager.play_spatial_sound(audio, global_position)
	if hit_vfx:
		VFX.spawn(hit_vfx, self)
	_flash_color()

func make_invulnerable(duration : float = 1.0)-> void:
	is_invulnerable = true
	await get_tree().create_timer(duration).timeout
	is_invulnerable = false

func _flash_color() -> void:
	#var mat: StandardMaterial3D = mesh.get_active_material(0).duplicate()
	#mat.albedo_color = hit_color
	#mesh.set_surface_override_material(0, mat)
	#
	#var timer := get_tree().create_timer(flash_duration, true, false, true)
	#timer.timeout.connect(_on_flash_done)
	pass

#func _on_flash_done() -> void:
	#mesh.set_surface_override_material(0, null)
	#pass
