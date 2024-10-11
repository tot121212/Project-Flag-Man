extends State
class_name LizardAggroState

@export var root: Node2D
@export var state_machine_parent : Node
@export var detection_raycaster : DetectionRaycaster

@export var target_group : String = "Player"

@export var aggro_timer : Timer # used to define how long aggro lasts after player is not visible anymore
var aggro_timer_lower_range : float = 6.0
var aggro_timer_upper_range : float = 12.0

var current_target : Node2D # node of player or the target of aggro in general
var distance_to_current_target : float
var direction_to_current_target : Vector2

@export var closest_target_acquisiton_timer : Timer # used by aggro states to proc closest target acquisition
var closest_target : Node2D
var distance_to_closest_target : float = -1

func state_enter():
	if not aggro_timer.timeout.is_connected(_on_aggro_timer_timeout):
		aggro_timer.timeout.connect(_on_aggro_timer_timeout)
	
	if not closest_target_acquisiton_timer.timeout.is_connected(find_closest_target):
		closest_target_acquisiton_timer.timeout.connect(find_closest_target)
	
	if closest_target_acquisiton_timer.is_stopped():
		closest_target_acquisiton_timer.start()
	
	if not detection_raycaster.is_colliding_with_target.is_connected(_on_detection_raycaster_is_colliding_with_target):
		detection_raycaster.is_colliding_with_target.connect(_on_detection_raycaster_is_colliding_with_target)
	
	reset_timer()
	choose_attack_state()

func state_exit():
	if detection_raycaster.is_colliding_with_target.is_connected(_on_detection_raycaster_is_colliding_with_target):
		detection_raycaster.is_colliding_with_target.disconnect(_on_detection_raycaster_is_colliding_with_target)
	
	if not closest_target_acquisiton_timer.is_stopped():
		closest_target_acquisiton_timer.stop()
	
	if closest_target_acquisiton_timer.timeout.is_connected(find_closest_target):
		closest_target_acquisiton_timer.timeout.disconnect(find_closest_target)
		
	if aggro_timer.timeout.is_connected(_on_aggro_timer_timeout):
		aggro_timer.timeout.disconnect(_on_aggro_timer_timeout)

func reset_timer():
	var duration = randf_range(aggro_timer_lower_range, aggro_timer_upper_range)
	aggro_timer.start(duration)

func choose_attack_state(): # choose either charge or spit as attack for lizard
	var chance = randi_range(0,3)
	if chance <= 3: # i have this at 0 for now while working on each state
		state_machine_parent.transition_state_machine_to_state("MovementAttackStateMachine", "LizardChargeMovement")
	else:
		state_machine_parent.transition_state_machine_to_state("MovementAttackStateMachine", "LizardSpitMovement")

func _on_detection_raycaster_is_colliding_with_target(_raycast, target):
	if target_group in target.get_groups():
		if aggro_timer.get_time_left() <= aggro_timer.wait_time / 2:
			if aggro_timer.is_connected("timeout", _on_aggro_timer_timeout):
				#print("LizardAggro: Aggro Timer extended on " + str(root.name))
				reset_timer()

func _on_aggro_timer_timeout():
	if not state_machine_parent.get_current_state_of_state_machine("MovementAttackStateMachine").name == "LizardChargeAttack":
		transition.emit(self, "LizardIdle")
	else:
		reset_timer()

func get_distance_to_target(target): # get distance from root to target
	return root.get_global_position().distance_to(target.get_global_position())

func get_direction_to_target(target):
	return root.get_global_position().direction_to(target.get_global_position())

func find_closest_target(): # check all targets in target_group for closest node to root
	#print("LizardAggro: Finding closest target")
	closest_target = get_tree().get_first_node_in_group(target_group)
	for target in get_tree().get_nodes_in_group(target_group):
		var distance_to_target : float = get_distance_to_target(target)
		
		if (distance_to_target
		and (distance_to_target < distance_to_closest_target or distance_to_closest_target == -1)):
			closest_target = target
			distance_to_closest_target = distance_to_target
	
	if not closest_target:
		print("LizardAggro: No Closest Target on " + str(root.name))
