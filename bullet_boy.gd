extends Node3D
#general
var animator #calls for local animator
#scale variables
var scaleton #skeleton variable
var scaleBone #bone that scales the main body
var parentBone #array that holds all the children of that bone
#eye closing controls
var openEyes
var closedEyes
#var scaler = 1.0
func _ready() -> void:
	animator = $AnimationPlayer
	
	scaleton = $Armature/Skeleton3D
	scaleBone = scaleton.find_bone("ScaleBone")
	parentBone = [scaleton.find_bone("Shoulder.R"),scaleton.find_bone("Shoulder.L"),scaleton.find_bone("Hip.R"),scaleton.find_bone("Hip.L"),scaleton.find_bone("Eyes_2")]
	
	openEyes = $Armature/Skeleton3D/Eyes
	closedEyes = $"Armature/Skeleton3D/ClosedEyes"
#call this when you want to rescale the player, scalef is your scale value, it's a float.
#this scales the main body and scales all the limbs and face inversely to keep them the same size, while still positioned on the main body
#this lets all the animations run fine regardless of scale (as long as bullet boy's feet are touching the ground at least)
func _scale_Boy(scalef:float):
	scaleton.set_bone_pose_scale(scaleBone,Vector3(scalef,scalef,scalef))
	for i in parentBone:
		scaleton.set_bone_pose_scale(i,Vector3(1.0/scalef,1.0/scalef,1.0/scalef))

#func _process(delta: float) -> void:
	#
	#_scale_Boy(scaler)
	#if (Input.is_key_pressed(KEY_F)):
		#scaler += delta
	#if (Input.is_key_pressed(KEY_D)):
		#animator.play("Dodge")
	#if (Input.is_key_pressed(KEY_S)):
		#animator.play("Shoot")
	#if (Input.is_key_pressed(KEY_A)):
		#animator.play("Hit")
	#if (Input.is_key_pressed(KEY_W)):
		#animator.play("RunForward")
	#if (Input.is_key_pressed(KEY_V)):
		#scaler -= delta


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	print(anim_name)
	if anim_name in ["Hit", "Dodge", "Shoot"]:
		print(anim_name)
		$Armature/Skeleton3D/Eyes.visible = false
		$Armature/Skeleton3D/ClosedEyes.visible = true
	else:
		$Armature/Skeleton3D/Eyes.visible = true
		$Armature/Skeleton3D/ClosedEyes.visible = false
		


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["Hit", "Dodge", "Shoot"]:
		$Armature/Skeleton3D/Eyes.visible = true
		$Armature/Skeleton3D/ClosedEyes.visible = false
	else:
		$Armature/Skeleton3D/Eyes.visible = true
		$Armature/Skeleton3D/ClosedEyes.visible = false
