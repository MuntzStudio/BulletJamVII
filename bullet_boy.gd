extends Node3D
#general
var animator #calls for local animator
#bullets
var bullets #reference for all bullets
var bulletSize  #the scale values that each bullet will appear at, 0 bullets is 0.5 scale, 8 bullets is 1.5 scale
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
	
	bullets = [$Armature/Skeleton3D/BulletRoot/Bullet_001,$Armature/Skeleton3D/BulletRoot/Bullet_002,$Armature/Skeleton3D/BulletRoot/Bullet_003,$Armature/Skeleton3D/BulletRoot/Bullet_004,$Armature/Skeleton3D/BulletRoot/Bullet_005,$Armature/Skeleton3D/BulletRoot/Bullet_006,$Armature/Skeleton3D/BulletRoot/Bullet_007,$Armature/Skeleton3D/BulletRoot/Bullet_007,$Armature/Skeleton3D/BulletRoot/Bullet_008]
	bulletSize = [0.635,0.75,0.875,1.0,1.125,1.25,1.375,1.5]
	
	scaleton = $Armature/Skeleton3D
	scaleBone = scaleton.find_bone("ScaleBone")
	parentBone = [scaleton.find_bone("Shoulder.R"),scaleton.find_bone("Shoulder.L"),scaleton.find_bone("Hip.R"),scaleton.find_bone("Hip.L"),scaleton.find_bone("Eyes_2"),scaleton.find_bone("BulletRoot")]
	
	openEyes = $Armature/Skeleton3D/Eyes
	closedEyes = $"Armature/Skeleton3D/ClosedEyes"
#call this when you want to rescale the player, scalef is your scale value, it's a float.
#this scales the main body and scales all the limbs and face inversely to keep them the same size, while still positioned on the main body
#this lets all the animations run fine regardless of scale (as long as bullet boy's feet are touching the ground at least)
func _scale_Boy(scalef:float):
	scaleton.set_bone_pose_scale(scaleBone,Vector3(scalef,scalef,scalef))
	for i in parentBone:
		scaleton.set_bone_pose_scale(i,Vector3(1.0/scalef,1.0/scalef,1.0/scalef))
	var i = 0
	for size in bulletSize: #checks the new scale against the scale value each bullet appears at and makes the right number of bullets visible accordingly 
		if scalef >= size:
			bullets[i].visible = true
		else:
			bullets[i].visible = false
		i += 1

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
