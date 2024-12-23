extends Menu

@export var flag_man_button : TextureButton
@export var continue_button : Button
@export var save_button : Button
@export var load_button : Button
@export var quit_button : Button
@export var controls_button : TextureButton

@export var main_menu_scene : PackedScene

@export var controls_menu_resource : MenuResource

func _enter_tree():
	super._enter_tree()
	hidden_by_default = true

func _ready() -> void:
	super._ready()
	continue_button.button_up.connect(_on_continue_button_clicked)
	save_button.button_up.connect(_on_save_button_clicked)
	load_button.button_up.connect(_on_load_button_clicked)
	quit_button.button_up.connect(_on_quit_button_clicked)
	controls_button.button_up.connect(_on_controls_button_clicked)

func _input(event: InputEvent) -> void:
	if event.is_action_released("escape_menu"):
		print(str(event) + "was pressed")
		toggle_menu()

func _on_continue_button_clicked():
	Utils.close_menu.emit(menu_resource)

func _on_save_button_clicked():
	SaveManager.save_game("0") # open first scene

func _on_load_button_clicked():
	SaveManager.load_game("0") # load existing game

func _on_quit_button_clicked():
	get_tree().change_scene_to_packed(main_menu_scene) # quit game

func _on_controls_button_clicked():
	Utils.close_menu.emit(menu_resource)
	Utils.open_menu.emit(controls_menu_resource)
