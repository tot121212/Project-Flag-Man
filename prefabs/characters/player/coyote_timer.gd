extends Timer
class_name CoyoteTimer

# Timer for detecting jump inputs a short time after the player has left the ground already.

@export var root : Node2D
@export var stats_component : StatsComponent

var is_in_air : bool = false

func _physics_process(_delta):
	if root.is_on_floor():
		if is_in_air:
			is_in_air = false
		if not is_stopped():
			stop_timer()
	
	if is_stopped() and not root.is_on_floor() and not is_in_air:
		is_in_air = true
		start_timer()

func start_timer():
	start()

func stop_timer():
	stop()
