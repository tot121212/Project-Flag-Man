extends State

@export var root: Node2D

@onready var aggro_timer : Timer = Timer.new()
var aggro_timer_lower_range : float = 12.0
var aggro_timer_upper_range : float = 24.0
var cur_aggro_target : Node

func _ready():
	aggro_timer.set_one_shot(true) # make sure timer stops after timeout
	aggro_timer.timeout.connect(_on_aggro_timer_timeout)
	add_child(aggro_timer)

func state_enter():
	reset_timer()
	#choose_attack_state()

#func state_physics_update(delta : float):
#func state_update(delta : float):

func reset_timer():
	var duration = randf_range(aggro_timer_lower_range, aggro_timer_upper_range)
	aggro_timer.start(duration)
	
func _on_detection_raycaster_is_colliding_with_target(_raycast, target):
	print("reset aggro")
	if "Player" in target.get_groups():
		if aggro_timer.get_time_left() <= aggro_timer.wait_time / 2:
			reset_timer()

func _on_aggro_timer_timeout():
	transition.emit(self, "LizardIdle")
	
func choose_attack_state(): # choose either charge or spit as attack for lizard
	var chance = randi_range(1,5)
	if chance > 3:
		root.movement_attack_state_machine.current_state.emit_signal(
			"transition",
			root.movement_attack_state_machine.current_state, "LizardChargeMovement")
	else: 
		root.movement_attack_state_machine.current_state.transition.emit(
			root.movement_attack_state_machine.current_state, "LizardSpitMovement")
