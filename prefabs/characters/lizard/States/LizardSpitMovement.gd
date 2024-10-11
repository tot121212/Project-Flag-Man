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

@export var aiming_raycast : RayCast2D

func state_enter():
	animation_player.set_current_animation("idle")
	
	lizard_aggro_state.find_closest_target() # find closest target
	lizard_aggro_state.current_target = lizard_aggro_state.closest_target
	
	navigation_component.set_target_position_safely(lizard_aggro_state.current_target.global_position)
	spit_navigation() #initialize

func state_physics_update(delta: float):
	if lizard_aggro_state.current_target != lizard_aggro_state.closest_target:
			lizard_aggro_state.current_target = lizard_aggro_state.closest_target
	
	if not navigation_agent.is_navigation_finished(): # if navigation not finished
		var next_pos = navigation_agent.get_next_path_position() # get next point
		if next_pos: # only change direction and move if wanting to move
			root.direction_of_next_nav_point = root.global_position.direction_to(next_pos).normalized()
			root.change_orientation.emit(root.direction_of_next_nav_point)
			if object_detect_raycasts.is_surface_front and root.is_on_floor() and not root.is_jumping:
				velocity_component.jump()
			velocity_component.move(delta, root.direction_of_next_nav_point, Vector2(stats_component.max_speed.x * 0.75, 0), Vector2(randf_range(-2,2), 0) )
	else: # once nav point is reached:
		aiming_raycast.target_position = lizard_aggro_state.current_target.global_position
		if aiming_raycast.is_colliding():
			transition.emit(self, "LizardSpitAttack")
		else:
			# find closest target and recurse
			# or
			# wait 0.3 seconds and recurse
			pass
		spit_navigation()

var actual_target_pos : Vector2
func spit_navigation():
	var closest_target_pos = lizard_aggro_state.closest_target.global_position
	var closest_target_pos_to_local = root.to_local(closest_target_pos)
	if sign(closest_target_pos_to_local.x) == -1:
		actual_target_pos = Vector2(closest_target_pos.x + randf_range(96, 128), closest_target_pos.y - 32)
	else:
		actual_target_pos = Vector2(closest_target_pos.x - randf_range(96, 128), closest_target_pos.y - 32)
	navigation_component.set_target_position_safely(actual_target_pos) # lizard nav to point a certain distance away that is the opposite direction of target itself
