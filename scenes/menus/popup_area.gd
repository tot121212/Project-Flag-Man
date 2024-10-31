extends Area2D
class_name PopupArea

@export var popup_to_open : StringName

# if player has entered area for the first time:
	#trigger a specific popup menu to open

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node2D):
	if body.is_in_group("Player"):
		Utils.popup_to_open.emit(popup_to_open)
		Utils.open_menu.emit("PopupMenu")
