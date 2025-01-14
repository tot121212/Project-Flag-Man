extends Node2D
class_name GravityComponent

@export var root : CharacterBody2D
@export var gravity_coefficient : float = 1 ## Manually affect gravity

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not root.is_on_floor():
		root.velocity.y += gravity * delta * gravity_coefficient
	root.move_and_slide()
