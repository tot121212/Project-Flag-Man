extends State
class_name LizardIdleState

@export var root: Node2D
@export var state_machine_parent : StateMachineParent
@export var detection_raycaster : DetectionRaycaster

func state_enter():
	# the movement attack state machine must load before this or...
	# it will not work due to the order in which it loads
	state_machine_parent.transition_state_machine_to_state("MovementAttackStateMachine", "LizardIdleMovement")
	if not detection_raycaster.is_colliding_with_target.is_connected(_on_detection_raycaster_is_colliding_with_target):
		detection_raycaster.is_colliding_with_target.connect(_on_detection_raycaster_is_colliding_with_target)
	
func state_exit():
	if detection_raycaster.is_colliding_with_target.is_connected(_on_detection_raycaster_is_colliding_with_target):
		detection_raycaster.is_colliding_with_target.disconnect(_on_detection_raycaster_is_colliding_with_target)

func _on_detection_raycaster_is_colliding_with_target(_raycast, target):
	if root.target_group in target.get_groups():
		transition.emit(self, "LizardAggro")
		#TODO: V
		print("Transition to LizardAggro should've happened.")
