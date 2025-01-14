extends Interactable
class_name VictoryFlag

@export var animation_player : AnimationPlayer
@export var flag_sprite : Sprite2D
@export var victory_message_resource : MessageResource
@export var area_2d : Area2D

func _ready():
	flag_sprite.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _is_player_in_area():
		GameState.set_stage_progress(GameState.get_current_stage(), true)
		_play_animation()

func _is_player_in_area():
	var bodies = area_2d.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group*("Player"):
			print("Player is inside of victory area")
			return true
	return false

var is_playing_anim : bool = false
func _play_animation():
	if !is_playing_anim:
		flag_sprite.show()
		animation_player.play("play")
		if !animation_player.animation_finished.is_connected(_on_animation_finished):
			animation_player.animation_finished.connect(_on_animation_finished)
		is_playing_anim = true

func _on_animation_finished(anim_name : StringName):
	if anim_name == "play":
		#await get_tree().create_timer(1.0)
		Utils.open_message.emit(victory_message_resource)
		await get_tree().create_timer(5.0).timeout
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
