extends Node2D

func _ready():
	Utils.set_current_stage("res://scenes/stages/stage_1.tscn")
	SaveManager.stage_ready.emit()
	
