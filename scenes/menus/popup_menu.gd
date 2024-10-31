extends Menu

@export var rich_text_label : RichTextLabel
var popup_to_open : StringName

var popup_text : Dictionary = {
	"welcome_press_esc_for_controls" = "Welcome to Flag Man!
To view the [color=a2bebe]controls[/color], press Start or Esc."
}

func _ready():
	Utils.popup_to_open.connect(_on_popup_to_open)
	Utils.open_menu.connect(_on_open_menu)

func _on_popup_to_open(name : StringName):
	popup_to_open = name

func _on_open_menu(text_name : StringName):
	if popup_text.has(text_name):
		rich_text_label.clear()
		rich_text_label.add_text(popup_text[text_name])
		return true
	return false
