extends State

@export var root: Node2D
@export var velocity_component : Node2D

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
	
	# initialize target
	closest_target = get_tree().get_first_node_in_group(target_group)
	if closest_target:
		distance_to_closest_target = get_distance_to_target(closest_target)
	# get actual target
	find_closest_target()
	
	# timer for finding closest target
	closest_target_acquisiton_timer.timeout.connect(_closest_target_acquisition_timer_timeout)
	closest_target_acquisiton_timer.start(0.5)

func state_exit():
	#closest_target = null 
		# charge state is being exited prematurely, why?
	distance_to_closest_target = -1.0
	closest_target_acquisiton_timer.stop()
	closest_target_acquisiton_timer.timeout.disconnect(_closest_target_acquisition_timer_timeout)

func state_physics_update(delta: float):
	if closest_target:
		#if root.global_position.distance_to(closest_target.global_position) < 50.0:
			#transition.emit(self, "LizardChargeAttack")
		
		root.direction = root.global_position.direction_to(closest_target.global_position)
		root.change_orientation.emit(root.direction)
		velocity_component.move(delta, root.direction)

func find_closest_target(): # check all targets in target_group for closest node to root
	for target in get_tree().get_nodes_in_group(target_group):
		var distance_to_target = get_distance_to_target(target)
		if distance_to_target and distance_to_closest_target > distance_to_target:
			closest_target = target
			distance_to_closest_target = distance_to_target

func get_distance_to_target(target): # get distance from root to target
	root.global_position.distance_to(target.global_position)

func _closest_target_acquisition_timer_timeout():
	find_closest_target()
