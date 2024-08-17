extends State

@export var root: Node2D

@onready var wander_timer : Timer = Timer.new()

var prev_wandered_randomly : bool = false

# wander for i amount of seconds in a random direction, re-randomizing if zero occurs
func wander_randomly(min_time, max_time):
	root.direction = Vector2.ZERO
	while root.direction == Vector2.ZERO:
		root.direction = Vector2(randi_range(-1,1), 0).normalized()
	wander_timer.start(randf_range(min_time, max_time))
	prev_wandered_randomly = true

# idle in place for i amount of seconds
func idle_in_place(min_time, max_time):
	root.direction = Vector2.ZERO
	wander_timer.start(randf_range(min_time, max_time))
	prev_wandered_randomly = false

func _ready():
	wander_timer.set_one_shot(true)
	wander_timer.timeout.connect(idle_logic)
	add_child(wander_timer)
	
func state_enter():
	idle_logic()

func state_exit():
	wander_timer.stop()

func idle_logic():
	var chance : int = randi_range(1,6)
	if not prev_wandered_randomly and chance > 3:
		wander_randomly(0.6, 2.0)
	else:
		idle_in_place(0.2, 1.1)

func state_physics_update(delta : float):
	if root.direction != Vector2.ZERO:
		idle_move(delta)
	else:
		root.velocity_component.apply_friction(delta)
	#detect cliff, pathfind to either jump or go opposite direction
	
func idle_move(delta):
	if root.is_on_floor():
		root.velocity_component.move(delta, root.direction)
		if root.prev_direction != root.direction:
			root.change_orientation.emit(root.direction)
		root.prev_direction = root.direction
