extends Node2D
class_name GravityComponent

@export var root : CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if root != null:
		if not root.is_on_floor():
			root.velocity.y += gravity * delta
		root.move_and_slide()
