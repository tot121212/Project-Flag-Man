extends State
class_name LizardSpitAttackState

@export var root : Node2D

@export var lizard_aggro_state : LizardAggroState
@export var lizard_spit_projectile_scene : PackedScene
@export var projectile_container : ProjectileContainer
@export var animation_player : AnimationPlayer

@export var spit_cooldown_timer : Timer # this timer shouldnt be ended on state_exit() bc we need to keep track of the cooldown continuosly

func state_enter():
	# TODO: we want slight seeking behaviour
	trigger_spit()
	
	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)

func state_exit():
	if animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.disconnect(_on_animation_finished)

func trigger_spit():
	var _direction_of_target = lizard_aggro_state.get_direction_to_target(lizard_aggro_state.current_target)
	root.change_orientation.emit(_direction_of_target)
	animation_player.current_animation = "spit"
	instantiate_spit(_direction_of_target)
	root.velocity.x += (sign(_direction_of_target.x) + 128)
	spit_cooldown_timer.start()

func instantiate_spit(_direction_of_target): # make new spit attack that is headed toward the closest_target
	var new_spit : Node
	if lizard_spit_projectile_scene.can_instantiate():
		new_spit = lizard_spit_projectile_scene.instantiate()
		if is_instance_valid(new_spit):
			projectile_container.add_child(new_spit)
			new_spit.projectile_component.direction = Vector2(snappedf(_direction_of_target.x, 0.1), snappedf(_direction_of_target.y, 0.1))
			new_spit.global_position = Vector2(root.global_position.x + (5 * signf(new_spit.projectile_component.direction.x)), root.global_position.y - 1)
		else:
			push_error("%s : New flag was not instantiated properly" % root.name)
	else:
		push_error("%s : Can't spawn projectile" % root.name)

func _on_animation_finished(anim_name):
	print("Anim finished: %s" % anim_name)
	if anim_name == "spit":
		transition.emit(self, "LizardSpitMovement")
