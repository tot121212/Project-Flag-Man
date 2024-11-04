extends Menu

@export var continue_button : Button

func _exit_tree():
	super._exit_tree()

func _enter_tree():
	super._enter_tree()
	hidden_by_default = true

func _ready() -> void:
	super._ready()
	continue_button.button_up.connect(_on_continue_button_down)

func _on_continue_button_down():
	Utils.close_menu.emit(menu_resource)
