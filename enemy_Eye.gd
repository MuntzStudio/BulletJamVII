extends Node3D



func _on_animation_player_animation_started(anim_name: StringName) -> void:
	print(anim_name)
	if anim_name in ["Hit", "Dodge", "Throw", "Fire"]:
		print(anim_name)
		$Armature/Skeleton3D/Eyes.visible = false
		$Armature/Skeleton3D/ClosedEyes.visible = true
	else:
		$Armature/Skeleton3D/Eyes.visible = true
		$Armature/Skeleton3D/ClosedEyes.visible = false
		


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["Hit", "Dodge", "Throw"]:
		$Armature/Skeleton3D/Eyes.visible = true
		$Armature/Skeleton3D/ClosedEyes.visible = false
	else:
		$Armature/Skeleton3D/Eyes.visible = true
		$Armature/Skeleton3D/ClosedEyes.visible = false
