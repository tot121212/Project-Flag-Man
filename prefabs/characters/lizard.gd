extends CharacterBody2D

@export var speed:float = 50


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta 
	
	if velocity.x < speed and velocity.x < speed:
		velocity.x += speed * delta
	
	move_and_slide()
