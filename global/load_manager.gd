## LoadManager - Autoload Singleton
extends CanvasLayer

var target_scene := ""
@onready var loading_bar: ProgressBar = $LoadingBar
@onready var anim_player: AnimationPlayer = $AnimationPlayer
var load_timer: float = 0.0
var load_delay: float = 0.0

func _ready() -> void:
	visible = false
	loading_bar.visible = false
	set_process(false)

func load_scene(path: String) -> void:
	load_timer = 0.0
	target_scene = path
	visible = true
	loading_bar.value = 0
	loading_bar.visible = false

	ResourceLoader.load_threaded_request(path)

	anim_player.play("fade_to_black")
	await anim_player.animation_finished
	set_process(true)

func _process(delta: float) -> void:
	if target_scene == "":
		return

	var progress: Array = []
	var status: int = ResourceLoader.load_threaded_get_status(target_scene, progress)

	if load_timer < load_delay:
		load_timer += delta

	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS and load_timer >= load_delay:
		loading_bar.visible = true
		loading_bar.value = progress[0] * 100

	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		loading_bar.visible = false
		set_process(false)  

		var scene: PackedScene = ResourceLoader.load_threaded_get(target_scene)
		target_scene = ""
		get_tree().change_scene_to_packed(scene)

		await get_tree().process_frame  
		anim_player.play("fade_from_black")
		await anim_player.animation_finished

		visible = false

	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("Failed to load: " + target_scene)
		target_scene = ""
		loading_bar.visible = false
		visible = false
		set_process(false)
