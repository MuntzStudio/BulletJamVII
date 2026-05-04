class_name Hitbox extends Area3D

@export var damage := 10.0
@export var knockback_force := 50.0
@export var hit_type : HitType = HitType.NORMAL  # enum for vfx/sound variation

enum HitType { NORMAL, EXPLOSION, PIERCE, FIRE }


func _ready() -> void:
	body_entered.connect( _on_body_entered )
	area_entered.connect( _on_body_entered )
	
	monitorable = false

func _on_body_entered(body : Node3D) -> void:
	if body is Hurtbox:
		body.take_damage(self)
		
		if body.is_in_group("enemy"):
			VFX.hitstop(0.2, 0.3)
		else:
			VFX.hitstop(0.5, 0.3)
		pass

func get_damage():
	return damage
