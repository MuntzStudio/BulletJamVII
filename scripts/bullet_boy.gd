extends Node3D

##bullets
var bullets #reference for all bullets
var bulletSize  #the scale values that each bullet will appear at, 0 bullets is 0.5 scale, 8 bullets is 1.5 scale

##scale variables
var scaleton #skeleton variable
var scaleBone #bone that scales the main body
var parentBone #array that holds all the children of that bone

##eye closing controls
var openEyes
var closedEyes
var eyes_closed_reasons := 0
var scaler = 1.0



func _ready() -> void:
	bullets = [
		$Armature/Skeleton3D/BulletRoot/Bullet_001,
		$Armature/Skeleton3D/BulletRoot/Bullet_002,
		$Armature/Skeleton3D/BulletRoot/Bullet_003,
		$Armature/Skeleton3D/BulletRoot/Bullet_004,
		$Armature/Skeleton3D/BulletRoot/Bullet_005,
		$Armature/Skeleton3D/BulletRoot/Bullet_006,
		$Armature/Skeleton3D/BulletRoot/Bullet_007,
		$Armature/Skeleton3D/BulletRoot/Bullet_008]
	bulletSize = [0.635,0.75,0.875,1.0,1.125,1.25,1.375,1.5]
	
	scaleton = $Armature/Skeleton3D
	scaleBone = scaleton.find_bone("ScaleBone")
	parentBone = [
		scaleton.find_bone("Shoulder.R"),
		scaleton.find_bone("Shoulder.L"),
		scaleton.find_bone("Hip.R"),
		scaleton.find_bone("Hip.L"),
		scaleton.find_bone("Eyes_2"),
		scaleton.find_bone("BulletRoot"),
	]
	openEyes = $Armature/Skeleton3D/Eyes
	closedEyes = $"Armature/Skeleton3D/ClosedEyes"

##call this when you want to rescale the player, scalef is your scale value, it's a float.
##this scales the main body and scales all the limbs and face inversely to keep them the same size, while still positioned on the main body
##this lets all the animations run fine regardless of scale (as long as bullet boy's feet are touching the ground at least)

func _scale_Boy(scalef: float) -> void:
	scaleton.set_bone_pose_scale(scaleBone, Vector3(scalef, scalef, scalef))
	for i in parentBone:
		scaleton.set_bone_pose_scale(i, Vector3(1.0/scalef, 1.0/scalef, 1.0/scalef))

func update_bullets(current_bullets: int) -> void:
	for i in bullets.size():
		bullets[i].visible = i < current_bullets

func _open_eyes() -> void:
	eyes_closed_reasons = max(eyes_closed_reasons - 1, 0)
	if eyes_closed_reasons != 0:
		return
	
	openEyes.visible = true
	closedEyes.visible = false

func _close_eyes() -> void:
	eyes_closed_reasons += 1
	if closedEyes.visible:
		return
	
	openEyes.visible = false
	closedEyes.visible = true
