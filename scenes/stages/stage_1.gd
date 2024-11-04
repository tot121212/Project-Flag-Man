extends GameStage
class_name StageDemo

func _ready():
	GameState.set_current_stage("res://scenes/stages/stage_1.tscn")
	SaveManager.stage_ready.emit()
