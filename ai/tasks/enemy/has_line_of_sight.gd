@tool
extends BTCondition
## Returns SUCCESS if agent has clear line of sight to target.
## Returns FAILURE if target is invalid or blocked by wall.

@export var target_var: StringName = &"target"
@export var ray_offset: Vector3 = Vector3(0, 0.5, 0)  # shoot from chest height

func _generate_name() -> String:
	return "HasLineOfSight to %s" % LimboUtility.decorate_var(target_var)

func _tick(_delta: float) -> Status:
	var target: Node3D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE

	var space = agent.get_world_3d().direct_space_state
	var from = agent.global_position + ray_offset
	var to = target.global_position + ray_offset

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [agent]  # don't hit yourself
	query.collision_mask = 1  # world only

	var result = space.intersect_ray(query)

	if result.is_empty():
		return SUCCESS  
	
	# Check if what it hit is the target or its child
	var hit = result.collider
	while hit:
		if hit == target:
			return SUCCESS
		hit = hit.get_parent()
	
	return FAILURE  # wall is blocking
