extends Projectile
class_name PlayerFlag

signal change_orientation
signal was_queue_freed

@export var animation_player : AnimationPlayer
@export var flag_shapes : Array[CollisionShape2D]

@export var non_frozen_layers : Array[int] = [6]
@export var non_frozen_masks : Array[int] = [1,4]
@export var frozen_layers : Array[int] = [5]
var is_frozen : bool = false

@export var detect_terrain_surface_area_2d : Area2D

#@export var one_way_collision_shapes : Array[CollisionShape2D]

func _ready():
	#change_one_way_based_on_direction()
	projectile_component.proj_delete_self.connect(_on_delete_self)
	animation_player.animation_finished.connect(_on_proj_free)
	animation_player.play("flying")

func _physics_process(_delta: float) -> void:
	if not is_frozen:
		var is_colliding = move_and_slide()
		move_slide_and_handle_collisions(is_colliding)

func apply_collision_effects(collider): # custom collision effects based on projectile type and settings
	if collider.is_in_group("Enemy"):
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

func freeze():
	if not detect_terrain_surface_area_2d.has_overlapping_bodies():
		if not is_frozen:
			is_frozen = true
		if not projectile_component.lifespan_timer.is_paused():
			projectile_component.lifespan_timer.set_paused(true)
		
		for layer in non_frozen_layers:
			set_collision_layer_value(layer, false)
		for layer in frozen_layers:
			set_collision_layer_value(layer, true)

func unfreeze():
	if is_frozen:
		is_frozen = false
	if projectile_component.lifespan_timer.is_paused():
		projectile_component.lifespan_timer.set_paused(false)
	
	for layer in frozen_layers:
		set_collision_layer_value(layer, false)
	for layer in non_frozen_layers:
		set_collision_layer_value(layer, true)

#func change_one_way_based_on_direction():
	#match projectile_component.direction:
		#Vector2(-1,0), Vector2(1,0):
			#for shape in one_way_collision_shapes:
				#shape.one_way_collision_direction = Vector2(0, -1)
		#Vector2(0,-1):
			#for shape in one_way_collision_shapes:
				#shape.one_way_collision_direction = Vector2(1, 0)
		#Vector2(0, 1):
			#for shape in one_way_collision_shapes:
				#shape.one_way_collision_direction = Vector2(-1, 0)
		#_:
			#return

# NOTE TO FUTURE SELF : Need to add one way collisions somehow, it will make gameplay better
