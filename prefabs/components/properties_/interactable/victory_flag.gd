extends Interactable
class_name VictoryFlag

@export var animation_player : AnimationPlayer
@export var flag_sprite : Sprite2D
@export var victory_message_resource : MessageResource

func _ready():
	flag_sprite.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		Utils.win_current_stage.emit()

func _play_animation():
	flag_sprite.show()
	animation_player.play("play")
	animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name : StringName):
	if anim_name == "play":
		#await get_tree().create_timer(1.0)
		Utils.open_message.emit(victory_message_resource)
