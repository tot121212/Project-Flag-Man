extends State

@export var root: Node2D
@export var stats_component : StatsComponent
@export var velocity_component : VelocityComponent
@export var navigation_component: NavigationComponent
@export var navigation_agent: NavigationAgent2D
@export var object_detect_raycasts : ObjectDetectRaycasts

@export var wander_distance : int = 200
var wander_timer : Timer

func _ready():
	wander_timer = Timer.new()
	add_child(wander_timer)

func state_enter():
	wander_timer.timeout.connect(_idle_logic)
	_idle_logic()

func state_exit():
	wander_timer.timeout.disconnect(_idle_logic)
	wander_timer.stop()

func state_physics_update(delta : float):
	if not navigation_agent.is_navigation_finished(): # if navigation not finished
		var next_pos = navigation_agent.get_next_path_position() # get next point
		if next_pos: # only change direction and move if wanting to move
			var direction_of_target_from_root = root.global_position.direction_to(next_pos).normalized()
			#if root.is_on_floor() and not velocity_component.is_jumping and object_detect_raycasts.is_surface_front:
			#	velocity_component.jump()
			if root.is_on_floor() and object_detect_raycasts.is_surface_front:
				
				var raycast_dir_x : float = object_detect_raycasts.raycast_front.get_collision_normal().x * -1 # get opposite of normal from collision to determine where to go
				var flee_from_edge_direction_x = raycast_dir_x * -1 # go opposite of that direction
				wander_in_direction(flee_from_edge_direction_x, 1.0, 2.0)
			
			if root.is_on_floor() and object_detect_raycasts.is_surface_front_down: # only move if there is a surface to walk on
				velocity_component.move(delta, direction_of_target_from_root, stats_component.max_speed.x * 0.3)

func random_direction():
	var direction := Vector2.ZERO
	while direction == Vector2.ZERO:
		root.direction = Vector2(randi_range(-1,1), 0).normalized()
	return direction

func wander_in_direction(direction, min_time, max_time):
	wander_timer.start(randf_range(min_time, max_time))
	navigation_component.set_target_position(Vector2(root.global_position.x + randi_range(0, wander_distance * direction.x), root.global_position.y))

func idle_in_place(min_time, max_time): # idle in place for i amount of seconds
	wander_timer.start(randf_range(min_time, max_time))
	navigation_component.set_target_position(root.global_position)

func _idle_logic():
	var chance : int = randi_range(1,6)
	if chance > 3:
		wander_in_direction(random_direction(), 2, 3)
	else:
		idle_in_place(1, 2)

