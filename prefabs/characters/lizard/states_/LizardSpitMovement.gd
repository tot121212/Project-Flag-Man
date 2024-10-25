extends State

@export var root : Node2D

# ideally we want the lizard to move a certain amount of blocks away from the player and then fire its projectile at the player

@export var velocity_component : VelocityComponent
@export var navigation_agent : NavigationAgent2D
@export var navigation_component : NavigationComponent
@export var object_detect_raycasts : ObjectDetectRaycasts
@export var stats_component : StatsComponent
@export var animation_player : AnimationPlayer
@export var detection_raycaster : DetectionRaycaster

@export var lizard_aggro_state : LizardAggroState
@export var lizard_spit_attack_state : LizardSpitAttackState

@export var closest_target_acquisiton_timer : Timer

func state_enter():
	animation_player.set_current_animation("idle")
	
	lizard_aggro_state.find_closest_target() # find closest target
	lizard_aggro_state.current_target = lizard_aggro_state.closest_target
	
	navigation_component.set_target_position_safely(lizard_aggro_state.current_target.global_position)
	
	if not closest_target_acquisiton_timer.timeout.is_connected(_on_closest_target_acquisition_timer_timeout):
		closest_target_acquisiton_timer.timeout.connect(_on_closest_target_acquisition_timer_timeout)
	
	if not detection_raycaster.is_colliding_with_target.is_connected(_on_detection_raycaster_is_colliding_with_target):
		detection_raycaster.is_colliding_with_target.connect(_on_detection_raycaster_is_colliding_with_target)
	

func state_exit():
	if detection_raycaster.is_colliding_with_target.is_connected(_on_detection_raycaster_is_colliding_with_target):
		detection_raycaster.is_colliding_with_target.disconnect(_on_detection_raycaster_is_colliding_with_target)
	
	if closest_target_acquisiton_timer.timeout.is_connected(_on_closest_target_acquisition_timer_timeout):
		closest_target_acquisiton_timer.timeout.disconnect(_on_closest_target_acquisition_timer_timeout)

func state_physics_update(delta: float):
	if lizard_aggro_state.current_target != lizard_aggro_state.closest_target:
			lizard_aggro_state.current_target = lizard_aggro_state.closest_target
	
	if not navigation_agent.is_navigation_finished(): # if navigation not finished
		var next_pos = navigation_agent.get_next_path_position() # get next point
		if next_pos: # only change direction and move if wanting to move
			root.direction_of_next_nav_point = root.global_position.direction_to(next_pos).normalized()
			
			if object_detect_raycasts.is_surface_front and root.is_on_floor() and not root.is_jumping:
				velocity_component.jump()
			root.change_orientation.emit(root.direction_of_next_nav_point)
			velocity_component.move(delta, root.direction_of_next_nav_point, Vector2(stats_component.max_speed.x * 0.75, 0), Vector2(randf_range(-2,2), 0) )
	else:
		root.change_orientation.emit(root.global_position.direction_to(lizard_aggro_state.current_target.global_position).normalized())
	
	if target_is_visible:
		if lizard_spit_attack_state.spit_cooldown_timer.is_stopped():
			transition.emit(self, "LizardSpitAttack")
		target_is_visible = false

func _on_closest_target_acquisition_timer_timeout():
	if lizard_aggro_state.current_target != lizard_aggro_state.closest_target:
			lizard_aggro_state.current_target = lizard_aggro_state.closest_target
	var current_target_pos = lizard_aggro_state.current_target.global_position
	var current_target_pos_to_local = root.to_local(current_target_pos)
	var actual_target_pos : Vector2
	if sign(current_target_pos_to_local.x) == 1:
		actual_target_pos = Vector2(current_target_pos.x - randf_range(128, 192), current_target_pos.y)
	else:
		actual_target_pos = Vector2(current_target_pos.x + randf_range(128, 192), current_target_pos.y)
	navigation_component.set_target_position_safely(actual_target_pos)

var target_is_visible : bool = false
func _on_detection_raycaster_is_colliding_with_target(_raycast, target):
	if target == lizard_aggro_state.current_target and target_is_visible == false:
		target_is_visible = true
