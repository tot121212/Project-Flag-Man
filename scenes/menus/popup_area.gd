extends Area2D
class_name PopupArea

@export var menu_to_trigger : StringName

# if player has entered area for the first time:
	#trigger a specific popup menu to open

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node2D):
	if body.is_in_group("Player"):
		Utils.trigger_menu(menu_to_trigger)
		
