extends Hitbox

@export var speed: float = 25.0
@export var lifetime: float = 2.0

var direction: Vector3 = Vector3.ZERO

func _ready():
	super._ready()
	set_active(true)
	body_entered.connect(_on_hit)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	position += direction * speed * delta

func _on_hit(_body: Node3D) -> void:
	queue_free()
