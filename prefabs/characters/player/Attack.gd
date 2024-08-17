extends State
class_name PlayerCombatAttack

@export var root : Node2D
@export var sparkles_sprite : Sprite2D

func state_update(_delta):
	if Input.is_action_just_pressed("use"):
		root.is_attacking = true
		print_debug("player attack")
		root.update_animation_parameters()
	else:
		root.is_attacking = false
