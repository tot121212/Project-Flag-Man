extends Menu
class_name MainMenu

@export var node_2d : Node2D
@export var marker : Marker2D

@export var flag_man_button : Control
@export var start_button : Button
@export var load_button : Button
@export var quit_button : Button

@export var player_scene : PackedScene

var secret = 0 ## lil secret

func _ready() -> void:
	## in case you dont understand,
	## super ready runs the parent class' ready function
	## if i didnt do this, the Menu ready function would not run, as it is overriden
	super._ready()
	flag_man_button.button_up.connect(_on_flag_man_button_clicked)
	start_button.button_up.connect(_on_start_button_clicked)
	load_button.button_up.connect(_on_load_button_clicked)
	quit_button.button_up.connect(_on_quit_button_clicked)
	load_button.grab_focus()

func _on_flag_man_button_clicked():
	secret += 1
	if secret == 3:
		flag_man_button.hide()
		var instance = player_scene.instantiate()
		instance.global_position = marker.global_position
		node_2d.add_child(instance)

func _on_start_button_clicked():
	SaveManager.new_game("0") # open first scene

func _on_load_button_clicked():
	SaveManager.load_game("0") # load existing game

func _on_quit_button_clicked():
	get_tree().quit() # quit game
