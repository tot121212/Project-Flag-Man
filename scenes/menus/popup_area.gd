extends Area2D
class_name PopupMessageArea

@export var message_to_open_resource : MessageResource

# if player has entered area for the first time:
	#trigger a specific popup menu to open

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node2D):
	if body.is_in_group("Player"):
		print("Player has entered %s" % self.name)
		Utils.open_message.emit(message_to_open_resource)
