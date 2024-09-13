extends State

@export var root: Node2D
@export var velocity_component : Node2D
@export var navigation_agent : NavigationAgent2D
@export var object_detect_raycasts : ObjectDetectRaycasts
@export var stats_component : StatsComponent

@export var target_group : String = "Player"

var closest_target
var distance_to_closest_target
var closest_target_acquisiton_timer : Timer

func _ready():
	closest_target_acquisiton_timer = Timer.new()
	add_child(closest_target_acquisiton_timer)

func state_enter():
	# wait a second or two for spice
	# await get_tree().create_timer(randf_range(0.6, 1.2)).timeout
	
	# initialize first target
	find_closest_target()
	
	# timer for finding closest target
	closest_target_acquisiton_timer.timeout.connect(find_closest_target)
	closest_target_acquisiton_timer.start(0.5)

func state_exit():
	closest_target_acquisiton_timer.stop()
	closest_target_acquisiton_timer.timeout.disconnect(find_closest_target)

func state_physics_update(delta: float):
	if closest_target: # attack if able first
		if (get_distance_to_target(closest_target) < 15.0 
		#and abs(root.global_position.y - closest_target.global_position.y) <= 5.0
		):
			transition.emit(self, "LizardChargeAttack")
	
	# else, we movin
	if not navigation_agent.is_navigation_finished(): # if navigation not finished
		var next_pos = navigation_agent.get_next_path_position() # get next point
		print(next_pos)
		if next_pos: # only change direction and move if wanting to move
			var direction_of_target_from_root = root.global_position.direction_to(next_pos).normalized()
			
			if object_detect_raycasts.is_surface_front and root.is_on_floor() and not velocity_component.is_jumping:
				velocity_component.jump()
			
			velocity_component.move(delta, direction_of_target_from_root, Vector2(stats_component.max_speed.x, 0))
			root.change_orientation.emit(direction_of_target_from_root)

func find_closest_target(): # check all targets in target_group for closest node to root
	if not closest_target:
		closest_target = get_tree().get_first_node_in_group(target_group)
		if closest_target:
			distance_to_closest_target = get_distance_to_target(closest_target)
		else: 
			print("no closest target")
			return
	
	for target in get_tree().get_nodes_in_group(target_group):
		var distance_to_target = get_distance_to_target(target)
		if distance_to_target and distance_to_target < distance_to_closest_target:
			closest_target = target
			distance_to_closest_target = distance_to_target
	
	print("Closest Target: " + closest_target.name)

func get_distance_to_target(target): # get distance from root to target
	return root.global_position.distance_to(target.global_position)
