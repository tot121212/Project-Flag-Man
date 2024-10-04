extends Control

@export var stats_component : StatsComponent
@export var hp_text : Sprite2D
@export var flag_pole : Sprite2D
@export var flag : Sprite2D

func _ready():
	stats_component.health_changed.connect(_on_health_changed)

func _on_health_changed():
	if stats_component.cur_health >= stats_component.max_health:
		hp_text.set_visible(true)
		flag_pole.set_visible(true)
		flag.set_visible(true)
	elif stats_component.cur_health >= stats_component.max_health * 0.66:
		hp_text.set_visible(true)
		flag_pole.set_visible(true)
		flag.set_visible(false)
	elif stats_component.cur_health >= stats_component.max_health * 0.33:
		hp_text.set_visible(true)
		flag_pole.set_visible(false)
		flag.set_visible(false)
	else: # elif stats_component.cur_health >= 0:
		hp_text.set_visible(false)
		flag_pole.set_visible(false)
		flag.set_visible(false)
