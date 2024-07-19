extends Node2D

@export var object : CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if object != null:
		if not object.is_on_floor():
			object.velocity.y += gravity * delta 
		object.move_and_slide()
