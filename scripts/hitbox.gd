class_name Hitbox extends Area3D

@export var damage := 10.0
@export var knockback_force := 50.0
@export var hit_type : HitType = HitType.NORMAL  # enum for vfx/sound variation
enum HitType { NORMAL, EXPLOSION, PIERCE, FIRE }

func _ready() -> void:
	area_entered.connect( _on_area_entered )
	monitorable = true


func _on_area_entered(body : Node3D) -> void:
	if body is Hurtbox:
		body.take_damage(self)

func activate(duration: float = 0.1) -> void:
	set_active()
	await get_tree().create_timer(duration).timeout
	set_active(false)
	pass

func set_active(value: bool = true) -> void:
	monitoring = value
	monitorable = value
	visible = value
	pass

func get_damage():
	return damage
