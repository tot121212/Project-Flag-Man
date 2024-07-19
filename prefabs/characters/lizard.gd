extends CharacterBody2D
class_name EnemyLizard

# signals for flipping
signal flip_h
signal flip_v

@export var sprite : Sprite2D

@export var max_speed : float = 75.0
@export var speed : float = 50.0
@export var health : int = 1
	
func _physics_process(delta):
	move_and_slide()
