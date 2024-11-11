extends Node2D
class_name StatsComponent

signal health_changed

@export var root : Node2D

@export var can_walk : bool = true
@export var can_fly : bool = false

@export var max_speed : Vector2 = Vector2(96.0, 128.0)
func get_max_speed():
	return max_speed

@export var initial_jump_speed : float = 128.0 ## initial speed of jump
@export var jump_speed : float = 64.0 ## constant speed after initial jump up to maximum (whilst holding jump button)
@export var jump_time : float = 0.5 ## maximum time of jump
@onready var max_jump_height = calculate_max_jump_height()

@export var max_health : int = 1
var cur_health : int = -1
var prev_health : int = -1

func _ready():
	set_cur_health(max_health)

func calculate_max_jump_height():
	# height during initial jump phase
	# average velocity during intial jump
	var average_speed_initial = (initial_jump_speed + jump_speed / 2)
	var height_initial = average_speed_initial * jump_time
	
	var height_sustained = jump_speed * jump_time
	
	var final_answer = height_initial + height_sustained
	print("Max Jump Height for " + root.name + " is " + str(final_answer))
	return final_answer


func set_cur_health(new_health : int) -> void:
	prev_health = clamp(cur_health, 0, max_health)
	cur_health = clamp(new_health, 0, max_health)
	health_changed.emit(cur_health, prev_health)
	print("Health changed on %s" % root.name)

func take_damage(damage):
	print(root.name + " took " + str(damage) + " damage ")
	set_cur_health(cur_health - abs(damage))

func heal(amount):
	set_cur_health(cur_health + abs(amount))
