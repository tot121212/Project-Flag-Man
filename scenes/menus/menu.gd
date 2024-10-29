extends Control
class_name Menu

@export var menu_name: StringName
@export var hidden_by_default : bool = false

var is_menu_open: bool = false

func _enter_tree():
	Utils.open_menu.connect(open_menu)
	Utils.close_menu.connect(close_menu)
	Utils.toggle_menu.connect(toggle_menu)

func _ready():
	if hidden_by_default:
		close_menu()

func _exit_tree():
	Utils.open_menu.disconnect(open_menu)
	Utils.close_menu.disconnect(close_menu)
	Utils.toggle_menu.disconnect(toggle_menu)

func set_is_menu_open(open: bool):
	is_menu_open = open

func get_is_menu_open() -> bool:
	return is_menu_open

func open_menu(input_menu_name: StringName = menu_name): 
	if input_menu_name == menu_name:
		if not get_tree().is_paused():
			get_tree().set_pause(true)
		if not self.is_visible():
			self.show()
			set_is_menu_open(true)

func close_menu(input_menu_name: StringName = menu_name):
	if input_menu_name == menu_name:
		if get_tree().is_paused():
			get_tree().set_pause(false)
		if self.is_visible():
			self.hide()
			set_is_menu_open(false)

func toggle_menu(input_menu_name: StringName = menu_name):
	if input_menu_name == menu_name:
		if not get_is_menu_open():
			open_menu(input_menu_name)
		else:
			close_menu(input_menu_name)

func check_is_menu_open(i: Callable = self.is_visible): 
	if i is Callable:
		set_is_menu_open(i.call())
	else:
		print("Did not input callable for %s" % self.name)
