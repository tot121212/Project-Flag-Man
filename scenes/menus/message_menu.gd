@tool
extends Menu
class_name MessageMenu

@export var rich_text_label : RichTextLabel
@export var continue_button : Button
@export var test_message_resource : MessageResource

func _enter_tree():
	super._enter_tree()
	hidden_by_default = true

func _ready():
	super._ready()
	continue_button.button_up.connect(_on_continue_pressed)
	Utils.open_message.connect(_on_open_message)

func _process(_delta : float) -> void:
	if Engine.is_editor_hint():
		_open_test_message()

var message_open : MessageResource
func _open_test_message():
	if message_open != test_message_resource: # to prevent it from causing lag
		_on_open_message(test_message_resource)

func _on_open_message(message_resource : MessageResource):
	message_open = message_resource
	print("Opening message: %s" % message_resource.message_name)
	rich_text_label.clear()
	rich_text_label.append_text(message_resource.message)
	Utils.open_menu.emit(menu_resource)

func _on_continue_pressed():
	Utils.close_menu.emit(menu_resource)
