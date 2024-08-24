extends State

@export var root : Node2D

func state_enter():
	transition.emit(self, "LizardChargeMovement")

func state_exit():
	pass
