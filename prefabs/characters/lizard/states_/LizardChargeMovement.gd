extends State

@export var root: Node2D
@export var velocity_component : VelocityComponent
@export var navigation_agent : NavigationAgent2D
@export var navigation_component : NavigationComponent
@export var object_detect_raycasts : ObjectDetectRaycasts
@export var stats_component : StatsComponent
@export var animation_player : AnimationPlayer

@export var lizard_charge_attack_state : State
@export var lizard_aggro_state : LizardAggroState

@export var closest_target_acquisiton_timer : Timer

@onready var charge_movement_speed : float = snappedf(stats_component.max_speed.x * 0.8, 0.01)

@export var distance_timer : Timer # timer for simply transitioning to spit attack state when not able to get to target for charge

func state_enter():
	animation_player.current_animation = "idle"
	
	lizard_aggro_state.find_closest_target() # find closest target
	lizard_aggro_state.current_target = lizard_aggro_state.closest_target
	
	navigation_component.set_target_position_safely(lizard_aggro_state.current_target.global_position)
	
	if not closest_target_acquisiton_timer.timeout.is_connected(_on_closest_target_acquisition_timer_timeout):
		closest_target_acquisiton_timer.timeout.connect(_on_closest_target_acquisition_timer_timeout)
	
	if not distance_timer.timeout.is_connected(_on_distance_timer_timeout):
		distance_timer.timeout.connect(_on_distance_timer_timeout)
	
	distance_timer.start()

func state_exit():
	distance_timer.stop()
	
	if distance_timer.timeout.is_connected(_on_distance_timer_timeout):
		distance_timer.timeout.disconnect(_on_distance_timer_timeout)
	
	if closest_target_acquisiton_timer.timeout.is_connected(_on_closest_target_acquisition_timer_timeout):
		closest_target_acquisiton_timer.timeout.disconnect(_on_closest_target_acquisition_timer_timeout)

func state_physics_update(delta : float):
	if lizard_aggro_state.closest_target: # attack if able first
		if lizard_aggro_state.current_target != lizard_aggro_state.closest_target:
			lizard_aggro_state.current_target = lizard_aggro_state.closest_target  
		
		if lizard_aggro_state.current_target:
			var root_to_local_of_current_target : Vector2 = root.to_local(lizard_aggro_state.current_target.global_position)
			if (abs(root_to_local_of_current_target.x) < 128.0
			and abs(root_to_local_of_current_target.y) < 32.0
			#and abs(root.get_global_position().direction_to(lizard_aggro_state.current_target.get_global_position()).y) <= 1
			and lizard_charge_attack_state.charge_cooldown_timer.is_stopped()
			):
				transition.emit(self, "LizardChargeAttack")
	
	if not navigation_agent.is_navigation_finished():
		var next_pos = navigation_agent.get_next_path_position() # get next point
		if next_pos: # only change direction and move if wanting to move
			
			root.direction_of_next_nav_point = root.global_position.direction_to(next_pos).normalized()
			root.change_orientation.emit(root.direction_of_next_nav_point)
			
			if object_detect_raycasts.is_surface_front and root.is_on_floor() and not velocity_component.is_jumping:
				velocity_component.move(delta, Vector2(-root.direction_of_next_nav_point.x,root.direction_of_next_nav_point.y), Vector2(charge_movement_speed, 0), Vector2(randf_range(-2,2), 0))
				velocity_component.jump()
			else:
				velocity_component.move(delta, root.direction_of_next_nav_point, Vector2(charge_movement_speed, 0), Vector2(randf_range(-2,2),0))
			
func _on_closest_target_acquisition_timer_timeout():
	if lizard_aggro_state.current_target != lizard_aggro_state.closest_target:
			lizard_aggro_state.current_target = lizard_aggro_state.closest_target
	
	var rng = -sign(lizard_aggro_state.get_direction_to_target(lizard_aggro_state.current_target).x) * (randf_range(32, 96))
	var target_pos = Vector2(lizard_aggro_state.current_target.global_position.x + rng, lizard_aggro_state.current_target.global_position.y)
	navigation_component.set_target_position_safely(target_pos)
	#print("LizardChargeMovement: Setting target position safely - " + lizard_aggro_state.current_target.name + " is at " + str(lizard_aggro_state.current_target.global_position))

func _on_distance_timer_timeout():
	transition.emit(self, "LizardSpitMovement")
