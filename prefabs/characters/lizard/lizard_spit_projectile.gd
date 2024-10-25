extends Projectile
class_name LizardSpitProjectile

signal change_orientation
signal was_queue_freed

@export var animation_player : AnimationPlayer

func _ready():
	#change_one_way_based_on_direction()
	projectile_component.proj_delete_self.connect(_on_delete_self)
	animation_player.animation_finished.connect(_on_proj_free)
	animation_player.play("flying")

func _physics_process(_delta: float) -> void:
	var is_colliding = move_and_slide()
	move_slide_and_handle_collisions(is_colliding)

func apply_collision_effects(collider): # custom collision effects based on projectile type and settings
	var components : Array[Node] = [
		collider.get_node_or_null("StatsComponent"),
		collider.get_node_or_null("VelocityComponent")
	]
	
	for component in components:
		if component is StatsComponent:
			if component.has_method("take_damage"):
				component.take_damage(projectile_component.damage)
			
			if component is VelocityComponent:
				if component.has_method("take_knockback"):
					var knockback = -get_velocity()
					component.take_knockback(knockback)
	projectile_component.proj_delete_self.emit()

func _on_delete_self(): # _on_delete_self and _on_proj_free are used to have an animation play first before the projectile is deleted
	# play anim of fading out
	if animation_player.has_animation("on_proj_free"):
		animation_player.play("on_proj_free", -1, 2.0)
		self.set_process(false)
		self.set_physics_process(false)
	else:
		_on_proj_free("on_proj_free")

func _on_proj_free(anim_name : StringName):
	if anim_name == "on_proj_free":
		was_queue_freed.emit(self)
		queue_free()
