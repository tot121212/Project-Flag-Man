extends Control

@export var node_2d : Node2D
@export var marker : Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel/HBoxContainer/FlagManButton.button_up.connect(_on_flag_man_button_clicked)
	$Panel/HBoxContainer/StartButton.button_up.connect(_on_start_button_clicked)
	$Panel/HBoxContainer/LoadButton.button_up.connect(_on_load_button_clicked)
	$Panel/HBoxContainer/QuitButton.button_up.connect(_on_quit_button_clicked)

var secret = 0
func _on_flag_man_button_clicked():
	secret += 1
	if secret == 3:
		$Panel/HBoxContainer/FlagManButton.hide()
		var scene = ResourceLoader.load("res://prefabs/characters/player/player.tscn") as PackedScene
		var instance = scene.instantiate()
		instance.global_position = marker.global_position
		node_2d.add_child(instance)
		

func _on_start_button_clicked():
	SaveManager.new_game("0") # open first scene

func _on_load_button_clicked():
	SaveManager.load_game("0") # load existing game

func _on_quit_button_clicked():
	get_tree().quit() # quit game
