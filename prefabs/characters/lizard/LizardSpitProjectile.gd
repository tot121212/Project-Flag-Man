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

func _physics_process(_delta):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("Player"):
			SignalBus.projectile_collision.emit(self, collider, projectile_component.damage)
			projectile_component.proj_delete_self.emit()
		elif collider.is_in_group("Terrain"):
			projectile_component.proj_delete_self.emit()
		print("Collided with: ", collision.get_collider().name)
	move_and_slide()

# _on_delete_self and _on_proj_free are used to have an animation play first before the projectile is deleted
func _on_delete_self():
	# play anim of fading out
	if animation_player.has_animation("on_proj_free"):
		animation_player.play("on_proj_free")
		self.set_process(false)
		self.set_physics_process(false)
	else:
		_on_proj_free("on_proj_free")

func _on_proj_free(anim_name : StringName):
	if anim_name == "on_proj_free":
		was_queue_freed.emit(self)
		queue_free()
