extends State

@export var root: Node2D
@export var velocity_component : VelocityComponent
@export var navigation_agent : NavigationAgent2D
@export var object_detect_raycasts : ObjectDetectRaycasts
@export var stats_component : StatsComponent
@export var animation_player : AnimationPlayer
@export var lizard_charge_attack_state : State

@export var target_group : String = "Player"

var closest_target
var distance_to_closest_target
var closest_target_acquisiton_timer : Timer # timer for finding closest target
var closest_target_acquisiton_timer_length : float = 0.5

func _ready():
	closest_target_acquisiton_timer = Timer.new()
	add_child(closest_target_acquisiton_timer)

func state_enter():
	animation_player.set_current_animation("idle")
	find_and_set_closest_target() # initialize first target
	closest_target_acquisiton_timer.timeout.connect(find_and_set_closest_target)
	closest_target_acquisiton_timer.start(closest_target_acquisiton_timer_length)

func state_exit():
	closest_target_acquisiton_timer.stop()
	closest_target_acquisiton_timer.timeout.disconnect(find_and_set_closest_target)

func state_physics_update(delta: float):
	if closest_target: # attack if able first
		if(get_distance_to_target(closest_target) < 96.0
		and abs(root.global_position.direction_to(closest_target.global_position).y) <= 0.1
		and lizard_charge_attack_state.charge_cooldown_timer.is_stopped()
		):
			transition.emit(self, "LizardChargeAttack")
	
	if not navigation_agent.is_navigation_finished(): # if navigation not finished
		var next_pos = navigation_agent.get_next_path_position() # get next point
		if next_pos: # only change direction and move if wanting to move
			
			root.direction_of_next_nav_point = root.global_position.direction_to(next_pos).normalized()
			root.change_orientation.emit(root.direction_of_next_nav_point)
			
			if object_detect_raycasts.is_surface_front and root.is_on_floor() and not root.is_jumping:
				velocity_component.jump()
				
			velocity_component.move(delta, root.direction_of_next_nav_point, Vector2(stats_component.max_speed.x * 0.75, 0), Vector2(randf_range(-2,2), 0) )

func find_and_set_closest_target(): # check all targets in target_group for closest node to root
	closest_target = get_tree().get_first_node_in_group(target_group) # initialize closest target
	
	if closest_target:
		distance_to_closest_target = get_distance_to_target(closest_target)
	else: 
		print_debug("no closest target")
		return
	
	for target in get_tree().get_nodes_in_group(target_group):
		var distance_to_target = get_distance_to_target(target)
		if distance_to_target and distance_to_target < distance_to_closest_target:
			closest_target = target
			distance_to_closest_target = distance_to_target
	
	navigation_agent.set_target_position(closest_target.global_position)

func get_distance_to_target(target): # get distance from root to target
	return root.global_position.distance_to(target.global_position)
