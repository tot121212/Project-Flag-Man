extends Timer
class_name CoyoteTimer
# Timer for detecting jump inputs a short time after the player has left the ground already.

@export var root : CharacterBody2D

func _physics_process(_delta):
	if root.is_on_floor() and not is_stopped():
		stop()
	
	if not root.is_on_floor() and is_stopped():
		start()
