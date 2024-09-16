extends Projectile
class_name PlayerFlag

signal change_orientation
signal was_queue_freed

@export var projectile_component : ProjectileComponent
@export var animation_player : AnimationPlayer
@export var flag_shapes : Array[CollisionShape2D]

var non_frozen_layers : Array[int] = [6]
var non_frozen_masks : Array[int] = [1,4]
var frozen_layers : Array[int] = [1]
var is_frozen : bool = false

func _ready():
	print("projectile spawned")
	projectile_component.proj_delete_self.connect(_on_delete_self)
	animation_player.animation_finished.connect(free_if_correct_anim)

func _physics_process(_delta):
	if not is_frozen:
		var is_colliding = move_and_slide()
		if is_colliding:
			_on_delete_self()

func _on_delete_self():
	# play anim of fading out
	animation_player.play("fade_sprite_out")
	self.set_process(false)
	self.set_physics_process(false)
	await animation_player.animation_finished

func free_if_correct_anim(anim_name : StringName):
	if anim_name == "fade_sprite_out":
		was_queue_freed.emit(self)
		queue_free()

func freeze():
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

# NOTE TO FUTURE SELF : Need to add one way collisions somehow, it will make gameplay better
