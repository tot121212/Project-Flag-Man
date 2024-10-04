extends State

@export var root: Node2D
@export var state_machine_parent : Node
@export var detection_raycaster : DetectionRaycaster

@onready var aggro_timer : Timer = Timer.new()
var aggro_timer_lower_range : float = 6.0
var aggro_timer_upper_range : float = 12.0
var cur_aggro_target : Node

func _ready():
	aggro_timer.set_one_shot(true) # make sure timer stops after timeout
	add_child(aggro_timer)

func state_enter():
	if not aggro_timer.timeout.is_connected(_on_aggro_timer_timeout):
		aggro_timer.timeout.connect(_on_aggro_timer_timeout)
	if not detection_raycaster.is_colliding_with_target.is_connected(_on_detection_raycaster_is_colliding_with_target):
		detection_raycaster.is_colliding_with_target.connect(_on_detection_raycaster_is_colliding_with_target)
	reset_timer()
	choose_attack_state()

func state_exit():
	if aggro_timer.timeout.is_connected(_on_aggro_timer_timeout):
		aggro_timer.timeout.disconnect(_on_aggro_timer_timeout)
	if detection_raycaster.is_colliding_with_target.is_connected(_on_detection_raycaster_is_colliding_with_target):
		detection_raycaster.is_colliding_with_target.disconnect(_on_detection_raycaster_is_colliding_with_target)

func reset_timer():
	var duration = randf_range(aggro_timer_lower_range, aggro_timer_upper_range)
	aggro_timer.start(duration)

func choose_attack_state(): # choose either charge or spit as attack for lizard
	var chance = randi_range(1,1)
	if chance > 0: # i have this at 0 for now while working on each state
		state_machine_parent.transition_state_machine_to_state("MovementAttackStateMachine", "LizardChargeMovement")
	else: 
		state_machine_parent.transition_state_machine_to_state("MovementAttackStateMachine", "LizardSpitMovement")

func _on_detection_raycaster_is_colliding_with_target(_raycast, target):
	if "Player" in target.get_groups():
		if aggro_timer.get_time_left() <= aggro_timer.wait_time / 2:
			if aggro_timer.is_connected("timeout", _on_aggro_timer_timeout):
				reset_timer()

func _on_aggro_timer_timeout():
	if not state_machine_parent.get_current_state_of_state_machine() == "LizardChargeAttack":
		transition.emit(self, "LizardIdle")
	else:
		reset_timer()
