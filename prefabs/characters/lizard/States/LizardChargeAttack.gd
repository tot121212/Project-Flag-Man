extends State

@export var root : Node2D

func state_enter():
	pass

func state_update(_delta):
	transition.emit(self, "LizardChargeMovement")

func state_exit():
	pass

func charge_in_direction(direction):
	pass
