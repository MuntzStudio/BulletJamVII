extends Node3D

@onready var flash: CPUParticles3D = $Flash
@onready var flare: CPUParticles3D = $Flare
@onready var shockwave: CPUParticles3D = $Shockwave

func _ready() -> void:
	flash.emitting = true
	flare.emitting = true
	shockwave.emitting = true
	
	await shockwave.finished
	queue_free()
