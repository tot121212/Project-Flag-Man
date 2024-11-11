extends Node2D

func _ready() -> void:
	SaveManager.stage_ready.emit()
