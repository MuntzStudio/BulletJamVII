class_name Boss extends CharacterBody3D

#region EXPORTS
@export var max_hp : int = 500
@export var phase2_threshold : float = 0.6   # 60% hp triggers phase 2
@export var phase3_threshold : float = 0.3   # 30% hp triggers phase 3
@export var hover_speed : float = 2.0
@export var hover_height : float = 0.3
@export var path_speed : float = 3.0
@export var health_bar: HealthBar
@export var death_vfx : PackedScene
@export var phase1: AudioStream
@export var phase2: AudioStream
@export var phase3: AudioStream
#endregion EXPORTS

#region NODE REFS
@onready var shield_boss: Node3D = $BossAnimPlayer
@onready var label: Label = get_tree().get_first_node_in_group("kill_label")
@onready var bullet_spawn: Node3D = $ShieldBoss/BulletSpawnPoint/BulletSpawn
@onready var attack_timer : Timer = $AttackTimer
@onready var path_follow: PathFollow3D = get_tree().get_first_node_in_group("path")
@onready var hurtbox: Hurtbox = $Hurtbox
#endregion NODE REFS

#region STATE
enum Phase { ONE, TWO, THREE }
var current_phase := Phase.ONE
var current_hp : int
var is_dead := false
var hover_time := 0.0
var is_attacking := false   # stops movement while attack animation plays
#endregion STATE

#region SIGNALS
signal phase_changed(new_phase)
signal boss_died
#endregion SIGNALS

#region READY & PROCESS
func _ready() -> void:
	health_bar.show()
	health_bar.init_health(max_hp)
	current_hp = max_hp
	
	# wired signals
	shield_boss.attack_finished.connect(_on_attack_finished)
	shield_boss.fire_bullets.connect(_shield_boss_fire_bullet)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	hurtbox.damage_taken.connect(_on_damage_taken)

func _notification(what):
	if what == NOTIFICATION_DISABLED:
		visible = false
		health_bar.hide()
		attack_timer.stop() 
	
	elif what == NOTIFICATION_ENABLED:
		visible = true
		health_bar.show()
		label.text = "|| BOSS AWAKENED ||"
		label.show()
		# boss starts with enter sequence, movement is stopped until it finishes
		_apply_phase(Phase.ONE)
		is_attacking = true
		shield_boss.play_enter()
		await get_tree().create_timer(0.73).timeout
		if is_dead: return
		_shield_boss_fire_bullet()
		label.hide()


func _process(delta: float) -> void:
	if is_dead:
		return
	_hover(delta)
	_move_on_path(delta)
#endregion READY & PROCESS

#region MOVEMENT
func _hover(delta: float) -> void:
	hover_time += delta
	position.y += sin(hover_time * hover_speed) * hover_height * delta

func _move_on_path(delta: float) -> void:
	if is_attacking:   # stops on path while attacking
		return
	path_follow.progress += path_speed * delta
	global_position.x = path_follow.global_position.x
	global_position.z = path_follow.global_position.z
#endregion MOVEMENT

#region HP & PHASES
func _on_damage_taken(hitbox: Hitbox) -> void:
	if is_dead:
		return
	current_hp -= int(hitbox.damage)
	current_hp = clamp(current_hp, 0, max_hp)
	health_bar._on_health_changed(current_hp, max_hp)
	shield_boss.play_hit()
	VFX.hitstop(0.1, 0.3)
	Events.screen_shake.emit(0.1, 0.2)
	_check_phase()
	if current_hp <= 0:
		_die()

func _check_phase() -> void:
	var ratio := float(current_hp) / float(max_hp)
	if current_phase == Phase.ONE and ratio <= phase2_threshold:
		_apply_phase(Phase.TWO)
		label.text = "||     PHASE 2 STARTED     ||"
		label.show()
		await get_tree().create_timer(2.0).timeout
		label.hide()
	elif current_phase == Phase.TWO and ratio <= phase3_threshold:
		_apply_phase(Phase.THREE)
		label.text = "||     PHASE 3 STARTED     ||"
		label.show()
		await get_tree().create_timer(2.0).timeout
		label.hide()

func _apply_phase(phase: Phase) -> void:
	current_phase = phase
	match phase:
		Phase.ONE:
			Audio.play_ambience(phase1)
			bullet_spawn.fire_rate    = 1.0
			bullet_spawn.bullet_count = 6
			bullet_spawn.spread_angle = 30.0
			attack_timer.wait_time    = 3.0
		Phase.TWO:
			Audio.play_ambience(phase2)
			bullet_spawn.fire_rate    = 3.0
			bullet_spawn.bullet_count = 12
			bullet_spawn.spread_angle = 60.0
			attack_timer.wait_time    = 1.8
			# speeding up boss
			path_speed *= 1.2
			# stop and do a phase transition attack before resuming
			is_attacking = true
			hurtbox.make_invulnerable(2.0)  #TODO add blink effect on phase transition
		Phase.THREE:
			Audio.play_ambience(phase3)
			bullet_spawn.fire_rate    = 6.0
			bullet_spawn.bullet_count = 24
			bullet_spawn.spread_angle = 180.0
			attack_timer.wait_time    = 1.8
			# speeding up boss
			path_speed *= 1.4
			# stop and do a phase transition attack before resuming
			is_attacking = true
			hurtbox.make_invulnerable(2.0)  #TODO add blink effect on phase transition
	attack_timer.start()            # need more phases if time
	emit_signal("phase_changed", phase)
#endregion HP & PHASES

#region ATTACK
func _on_attack_timer_timeout() -> void:
	if is_dead:
		return
	is_attacking = true
	hurtbox.make_invulnerable(1.0)
	shield_boss.play_attack()
	await get_tree().create_timer(0.43).timeout
	if is_dead: return
	_shield_boss_fire_bullet()

func _on_attack_finished() -> void:
	# resumes movement after attacking
	is_attacking = false

func _shield_boss_fire_bullet() -> void:
	bullet_spawn.fire()
#endregion ATTACK

#region DEATH
func _die() -> void:
	health_bar.hide()
	is_dead = true

	hurtbox.is_invulnerable = true

	attack_timer.stop()

	velocity = Vector3.ZERO
	set_physics_process(false)
	set_process(false)

	shield_boss.play_attack()
	emit_signal("boss_died")
	VFX.spawn(death_vfx, self)
	await get_tree().create_timer(.5).timeout
	VFX.spawn(death_vfx, self)
	await get_tree().create_timer(.5).timeout
	VFX.spawn(death_vfx, self)
	await get_tree().create_timer(2.3).timeout
	queue_free()
#endregion DEATH
