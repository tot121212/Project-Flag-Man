extends ToggleableMenu

func _ready() -> void:
	check_is_menu_open()
	if get_is_menu_open():
		close_menu()
	$Panel/HBoxContainer/FlagManButton.button_up.connect(_on_flag_man_button_clicked)
	$Panel/HBoxContainer/ContinueButton.button_up.connect(_on_continue_button_clicked)
	$Panel/HBoxContainer/SaveButton.button_up.connect(_on_save_button_clicked)
	$Panel/HBoxContainer/LoadButton.button_up.connect(_on_load_button_clicked)
	$Panel/HBoxContainer/QuitButton.button_up.connect(_on_quit_button_clicked)

func _on_flag_man_button_clicked():
	pass

func _on_continue_button_clicked():
	check_is_menu_open()
	if get_is_menu_open():
		close_menu()

func _on_save_button_clicked():
	SaveManager.save_game("0") # open first scene

func _on_load_button_clicked():
	SaveManager.load_game("0") # load existing game

func _on_quit_button_clicked():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn") # quit game

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape_menu"):
		print("input escape")
		toggle_menu()
