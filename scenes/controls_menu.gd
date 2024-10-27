extends ToggleableMenu

func _ready() -> void:
	check_is_menu_open()
	if get_is_menu_open():
		close_menu()
