extends Node2D
class_name StatsComponent

signal health_changed

@export var can_walk : bool = true
@export var can_fly : bool = false

@export var max_speed : Vector2 = Vector2(55.0, 40.0)

@export var initial_jump_speed : float = 75.0
@export var jump_speed : float = 35.0
@export var jump_time : float = 0.4

@export var max_health : int = 1
var cur_health : int = 1

func set_cur_health(new_health: int) -> void:
	cur_health = clamp(new_health, 0, max_health)
	health_changed.emit(cur_health)
