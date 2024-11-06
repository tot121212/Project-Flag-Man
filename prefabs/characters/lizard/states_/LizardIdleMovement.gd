extends State

@export var root: Node2D
@export var stats_component : StatsComponent
@export var velocity_component : VelocityComponent

@export var navigation_agent: NavigationAgent2D
@export var navigation_component: NavigationComponent

@export var object_detect_raycasts : ObjectDetectRaycasts
@export var patrol_points : PatrolPointsContainer
@export var animation_tree : AnimationTree

@export var wander_distance : int = 200
var wander_timer : Timer

func _ready():
	wander_timer = Timer.new()
	add_child(wander_timer)
	patrol_points.get_amt_of_patrol_points()

func state_enter():
	animation_tree["parameters/conditions/is_idling"] = true
	
	if not wander_timer.timeout.is_connected(idle_logic):
		wander_timer.timeout.connect(idle_logic)
	idle_logic()

func state_exit():
	wander_timer.stop()
	if wander_timer.timeout.is_connected(idle_logic):
		wander_timer.timeout.disconnect(idle_logic)
		
	animation_tree["parameters/conditions/is_idling"] = false
	
	patrol_points.should_return_to_patrol_point = false

func state_physics_update(delta : float):
	get_next_pos_and_move_jump(delta)

func get_next_pos_and_move_jump(delta):
	if not navigation_agent.is_navigation_finished(): # if navigation not finished
		var next_pos = navigation_agent.get_next_path_position() # get next point
		if next_pos: # only change direction and move if wanting to move
			root.direction_of_next_nav_point = root.global_position.direction_to(next_pos).normalized()
			#TODO: Need to determine if able to jump to an eligable point in next_pos' direction
			#      then, if its valid jump and jump arc needs to be calculated
			#      otherwise, navigate the other direction
			if root.is_on_floor() and not root.is_jumping and object_detect_raycasts.is_surface_front:
				velocity_component.jump()
			if root.is_on_floor():# and object_detect_raycasts.is_surface_front_down: # only move if there is a surface to walk on
				velocity_component.move(delta, root.direction_of_next_nav_point, Vector2(stats_component.max_speed.x * 0.3, 0), Vector2(randf_range(-2,2), 0) )
				root.change_orientation.emit(root.direction_of_next_nav_point)
	elif patrol_points.should_return_to_patrol_point: # else nav is finished, check if should return to patrol point is true
		patrol_points.should_return_to_patrol_point = false

func set_target_pos_to_flee_from_edges():
	if root.is_on_floor():
		if object_detect_raycasts.is_surface_front or not object_detect_raycasts.is_surface_front_down:
			var raycast_dir : float = object_detect_raycasts.raycast_front.get_collision_normal().x * -1 # get opposite of normal from collision to determine where to go
			var flee_from_edge_direction = Vector2(raycast_dir * -1, 0) # go opposite of that direction
			set_target_pos_to_random(flee_from_edge_direction, 1.0, 2.0)

func random_direction(): # returns a vector 2 with either -1,0 or 1,0
	var direction : Vector2 = Vector2.ZERO
	while direction.x == 0:
		direction = Vector2(randi_range(-1,1), 0).normalized()
	return direction

func set_target_pos_to_random(direction, min_time, max_time):
	wander_timer.start(randf_range(min_time, max_time))
	navigation_component.set_target_position_safely(Vector2(root.global_position.x + randi_range(0, wander_distance * direction.x), root.global_position.y))

func idle_in_place(min_time, max_time): # idle in place for i amount of seconds
	wander_timer.start(randf_range(min_time, max_time))
	navigation_component.set_target_position_safely(root.global_position)

func idle_between_patrol_points(min_time, max_time):
	wander_timer.start(randf_range(min_time, max_time))
	patrol_points.set_target_pos_to_next_patrol_point()

func return_to_closest_patrol_point():
	patrol_points.set_target_pos_to_closest_patrol_point()

func idle_logic(direction = random_direction()): # direction will be random by default
	if patrol_points.should_patrol_if_able and patrol_points.should_return_to_patrol_point:
		return_to_closest_patrol_point()
	else:
		var chance : int = randi_range(0,9)
		if chance > 2:
			if patrol_points.should_patrol_if_able and patrol_points.amt_of_patrol_points > 0:
				idle_between_patrol_points(3, 5)
				#print(root.name + ": LizardIdle: Pathing to patrol point")
			else:
				set_target_pos_to_random(direction, 2, 3)
				#print(root.name + ": LizardIdle: Pathing randomly")
		else:
			idle_in_place(1, 2)
