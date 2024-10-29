extends Menu

#func _ready() -> void:
	#check_is_menu_open()
	#if get_is_menu_open():
		#close_menu()

@export var continue_button : Button

func _ready() -> void:
	continue_button.button_down.connect(_on_continue_button_down)
	
func _on_continue_button_down():
	close_menu()
