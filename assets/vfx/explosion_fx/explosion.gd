extends Node3D

@onready var spark: CPUParticles3D = $Spark
@onready var smoke: CPUParticles3D = $Smoke

func _ready() -> void:
	await get_tree().process_frame
	smoke.emitting = true
	spark.emitting = true
	
	await smoke.finished
	queue_free()
