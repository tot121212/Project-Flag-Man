extends CharacterBody2D
class_name Projectile
# Inherit from Projectile and call the move_slide_and_handle_collisions function with the result of move_and_slide()

@export var projectile_component : ProjectileComponent

#region Example
#func _physics_process(_delta: float) -> void:
	#var is_colliding = move_and_slide()
	#move_slide_and_handle_collisions(is_colliding)
#endregion
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

#region Example
# @export var projectile_component : ProjectileComponent
#func apply_collision_effects(collider): # custom collision effects based on projectile type and settings
	#if collider.is_in_group("Enemy"):
		#var components : Array[Node] = [
			#collider.get_node_or_null("StatsComponent"),
			#collider.get_node_or_null("VelocityComponent")
		#]
		#
		#for component in components:
			#if component.has_method("take_damage"):
				#component.take_damage(projectile_component.damage)
			#
			#if component.has_method("take_knockback"):
				#var knockback = -get_velocity()
				#component.take_knockback(knockback)
	#projectile_component.free_projectile.emit()
#endregion
func apply_collision_effects(_collider : Node): # custom collision effects based on projectile type and settings, should be overriden by projectile descendents
	pass
