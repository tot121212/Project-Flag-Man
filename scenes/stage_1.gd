extends Node2D
class_name Stage1

func _ready():
	SaveManager.stage_ready.emit()
	
