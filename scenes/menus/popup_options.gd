extends Resource
class_name PopupOptionsResource

var popup_names : Array[StringName] = [
	"CONTROLS_MENU",
	"TUTORIAL_MENU_FOR_CONTROLS",
]

@export var popup: String

func get_popup_data_from_name(name : StringName):
	for n in popup_names:
		if name == n:
			pass
