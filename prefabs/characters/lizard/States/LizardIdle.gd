extends State

@export var body: Node2D

@export var target_group : String = "Player"

func state_enter():
	# the movement attack state machine must load before this or...
	# it will not work due to the order in which it loads
	
	body.movement_attack_state_machine.current_state.transition.emit(
		body.movement_attack_state_machine.current_state,
		"LizardIdleMovement")
		
	body.detection_raycaster.is_colliding_with_target.connect(_on_detection_raycaster_is_colliding_with_target)
	
func state_exit():
	body.detection_raycaster.is_colliding_with_target.disconnect(_on_detection_raycaster_is_colliding_with_target)

func _on_detection_raycaster_is_colliding_with_target(_raycast, target):
	if target_group in target.get_groups():
		transition.emit(self, "LizardAggro")
