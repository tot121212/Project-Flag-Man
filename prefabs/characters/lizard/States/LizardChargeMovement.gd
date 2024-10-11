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

func state_enter():
	animation_player.set_current_animation("idle")
	
	lizard_aggro_state.find_closest_target() # find closest target
	lizard_aggro_state.current_target = lizard_aggro_state.closest_target
	navigation_component.set_target_position_safely(lizard_aggro_state.current_target.global_position)
	
	if not closest_target_acquisiton_timer.timeout.is_connected(_on_closest_target_acquisition_timer_timeout):
		closest_target_acquisiton_timer.timeout.connect(_on_closest_target_acquisition_timer_timeout)

func state_exit():
	if closest_target_acquisiton_timer.timeout.is_connected(_on_closest_target_acquisition_timer_timeout):
		closest_target_acquisiton_timer.timeout.disconnect(_on_closest_target_acquisition_timer_timeout)

func state_physics_update(delta: float):
	if lizard_aggro_state.closest_target: # attack if able first
		if lizard_aggro_state.current_target != lizard_aggro_state.closest_target:
			lizard_aggro_state.current_target = lizard_aggro_state.closest_target
			
		if (lizard_aggro_state.get_distance_to_target(lizard_aggro_state.current_target) < 96.0
		and abs(root.get_global_position().direction_to(lizard_aggro_state.current_target.get_global_position()).y) <= 0.1
		and lizard_charge_attack_state.charge_cooldown_timer.is_stopped()
		):
			transition.emit(self, "LizardChargeAttack")
	
	if not navigation_agent.is_navigation_finished():
		var next_pos = navigation_agent.get_next_path_position() # get next point
		if next_pos: # only change direction and move if wanting to move
			
			root.direction_of_next_nav_point = root.global_position.direction_to(next_pos).normalized()
			root.change_orientation.emit(root.direction_of_next_nav_point)
			
			if object_detect_raycasts.is_surface_front and root.is_on_floor() and not root.is_jumping:
				velocity_component.move(delta, Vector2(-root.direction_of_next_nav_point.x , root.direction_of_next_nav_point.y), Vector2(stats_component.max_speed.x * 0.75, 0), Vector2(randf_range(-2,2), 0) )
				velocity_component.jump()
			else:
				velocity_component.move(delta, root.direction_of_next_nav_point, Vector2(stats_component.max_speed.x * 0.75, 0), Vector2(randf_range(-2,2), 0) )
			
func _on_closest_target_acquisition_timer_timeout():
	
	if lizard_aggro_state.current_target != lizard_aggro_state.closest_target:
			lizard_aggro_state.current_target = lizard_aggro_state.closest_target
	
	navigation_component.set_target_position_safely(lizard_aggro_state.current_target.global_position)
	#print("LizardChargeMovement: Setting target position safely - " + lizard_aggro_state.current_target.name + " is at " + str(lizard_aggro_state.current_target.global_position))
