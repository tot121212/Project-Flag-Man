extends State

@export var root: Node2D
@export var state_machine_parent : Node

@export var target_group : String = "Player"

func state_enter():
	# the movement attack state machine must load before this or...
	# it will not work due to the order in which it loads
	state_machine_parent.transition_state_machine_to_state("MovementAttackStateMachine", "LizardIdleMovement")
	root.detection_raycaster.is_colliding_with_target.connect(_on_detection_raycaster_is_colliding_with_target)
	root.not_surface_front_down.connect(_on_not_surface_front_down)
	root.surface_front.connect(_on_surface_front)
	
func state_exit():
	root.detection_raycaster.is_colliding_with_target.disconnect(_on_detection_raycaster_is_colliding_with_target)
	root.not_surface_front_down.disconnect(_on_not_surface_front_down)
	root.surface_front.disconnect(_on_surface_front)
	
func _on_detection_raycaster_is_colliding_with_target(_raycast, target):
	if target_group in target.get_groups():
		transition.emit(self, "LizardAggro")

func _on_not_surface_front_down(_raycast_target_position):
	# if jumpable path
		# jump
	# else
		# path away
	pass

func _on_surface_front(_raycast_collision_point):
	# if jumpable path
		# jump
	# else
		# path away
	pass
