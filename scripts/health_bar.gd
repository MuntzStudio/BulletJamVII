class_name HealthBar
extends ProgressBar

@onready var damage_bar: ProgressBar = $DamageBar
@onready var timer: Timer = $DamageTimer


# HOW LONG THE DAMAGE BAR TAKES TO SLIDE DOWN AFTER THE TIMER
@export var damage_bar_tween_duration := 0.4
@export var color_full := Color(0.2, 0.8, 0.2, 1.0)
@export var color_empty := Color(0.8, 0.1, 0.1, 1.0)

var health : float = 0 : set = _set_health
var fill_style: StyleBoxFlat
var _damage_tween: Tween

func _ready():
	fill_style = get_theme_stylebox("fill") as StyleBoxFlat



func _on_health_changed(current: float, max_health: float):
	# REINIT IF MAX HEALTH CHANGED
	if max_health != max_value:
		init_health(max_health)

	health = current


func _set_health(new_health):
	var prev_health = health
	health = clamp(new_health, 0.0, max_value)
	value = health

	_update_color()
	
	if health < prev_health:
		# DAMAGE - WAIT FOR TIMER THEN TWEEN DAMAGE BAR DOWN
		timer.start()
	else:
		# HEAL OR REINIT - SNAP DAMAGE BAR UP IMMEDIATELY
		if _damage_tween:
			_damage_tween.kill()
		damage_bar.value = health


func _update_color():
	# NULL GUARD - STYLEBOX MAY NOT BE A STYLEBOXFLAT
	if not fill_style:
		return
	var health_ratio := health / max_value if max_value > 0 else 1.0
	fill_style.bg_color = color_empty.lerp(color_full, health_ratio)

func init_health(_health):
	max_value = _health
	damage_bar.max_value = _health
	damage_bar.value = _health
	health = _health
	value = _health


func _on_damage_timer_timeout():
	# KILL ANY IN-PROGRESS TWEEN BEFORE STARTING A NEW ONE
	if _damage_tween:
		_damage_tween.kill()

	# SMOOTHLY SLIDE DAMAGE BAR DOWN TO CURRENT HEALTH
	_damage_tween = create_tween()
	_damage_tween.tween_property(damage_bar, "value", health, damage_bar_tween_duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
