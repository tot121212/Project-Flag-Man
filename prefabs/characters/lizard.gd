extends CharacterBody2D

@export var max_speed := 75.0
@export var speed := 50.0
@export var health := 1

@export var player_group := "Player"
@export var detection_range := 200.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta 
	
	if velocity.x < max_speed:
		velocity.x = move_toward(velocity.x, max_speed, speed * delta)
		velocity.x += speed * delta
	
	move_and_slide()

func take_damage(damage:float):
	health -= damage
	if health < 0:
		queue_free()
