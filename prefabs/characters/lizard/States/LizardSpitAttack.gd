extends State

@export var root : Node2D

@export var lizard_aggro_state : LizardAggroState
@export var lizard_spit_projectile_scene : PackedScene
@export var projectile_organizer : ProjectileOrganizer
@export var animation_player : AnimationPlayer

var spit_cooldown_timer : Timer # this timer shouldnt be ended on state_exit() 
								# bc we need to keep track of the cooldown continuosly

func state_enter():
	# we want slight seeking behaviour
	instantiate_spit()
	animation_player.set_current_animation("spit")

func state_exit():
	pass

func instantiate_spit(): # make new spit attack that is headed toward the closest_target
	var new_spit : Node
	if lizard_spit_projectile_scene.can_instantiate():
		new_spit = lizard_spit_projectile_scene.instantiate()
		if is_instance_valid(new_spit):
			projectile_organizer.add_child(new_spit)
			new_spit.projectile_component.direction = lizard_aggro_state.get_direction_to_target(lizard_aggro_state.closest_target)
			root.change_orientation.emit(new_spit.projectile_component.direction)
		else:
			push_warning("new flag was not instantiated properly")
	else:
		push_warning("cant spawn projectile")
