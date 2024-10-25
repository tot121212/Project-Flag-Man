extends Control

func _ready() -> void:
	close_menu()
	$Panel/HBoxContainer/FlagManButton.button_up.connect(_on_flag_man_button_clicked)
	$Panel/HBoxContainer/ContinueButton.button_up.connect(_on_continue_button_clicked)
	$Panel/HBoxContainer/SaveButton.button_up.connect(_on_save_button_clicked)
	$Panel/HBoxContainer/LoadButton.button_up.connect(_on_load_button_clicked)
	$Panel/HBoxContainer/QuitButton.button_up.connect(_on_quit_button_clicked)

func _on_flag_man_button_clicked():
	pass

func _on_continue_button_clicked():
	if is_menu_open():
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
		menu_open_or_close()

func is_menu_open():
	if is_visible():
		return true
	else:
		return false

func open_menu():
	if not get_tree().is_paused():
		get_tree().set_pause(true)
	if not is_visible():
		visible = true

func close_menu():
	if get_tree().is_paused():
		get_tree().set_pause(false)
	if is_visible():
		visible = false

func menu_open_or_close():
	if not is_menu_open():
		open_menu()
	else:
		close_menu()
