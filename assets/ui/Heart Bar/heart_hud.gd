extends CanvasLayer

@export var heart_scene: PackedScene

var hearts_container


func _ready() -> void:

	hearts_container = $MarginContainer/Hearts


func update_hearts(
	current_health: int,
	max_health: int
) -> void:
	#print("UPDATING HEARTS")
	# Safety
	if hearts_container == null:
		return


	# Remove old hearts
	for child in hearts_container.get_children():

		child.queue_free()


	# Number of heart slots
	var total_hearts = int(ceil(max_health / 2.0))


	for i in range(total_hearts):

		var heart = heart_scene.instantiate()
		#print(heart)
		hearts_container.add_child(heart)


		var health_left = current_health - (i * 2)


		# Full
		if health_left >= 2:

			heart.set_state(2)


		# Half
		elif health_left == 1:

			heart.set_state(1)


		# Empty
		else:

			heart.set_state(0)
