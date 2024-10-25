extends CharacterBody2D
class_name Projectile

@export var projectile_component : ProjectileComponent

func move_slide_and_handle_collisions(is_colliding): # requires move and slide result as input
	if is_colliding:
		handle_collisions()

func handle_collisions():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		print("Collided with: ", collision.get_collider().name)
		
		if collider is Node:
			apply_collision_effects(collider)

func apply_collision_effects(_collider : Node): # custom collision effects based on projectile type and settings, should be overriden by projectile derivatives
	pass
