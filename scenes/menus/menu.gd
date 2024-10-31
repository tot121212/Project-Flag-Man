extends Control
class_name Menu

@export var menu_name: StringName
@export var hidden_by_default : bool = false

var is_menu_open: bool = false

func _enter_tree():
	if not Utils.attach_menus_to_node.is_connected(_on_attach_menus_to_node):
		Utils.attach_menus_to_node.connect(_on_attach_menus_to_node)
	if not Utils.open_menu.is_connected(open_menu):
		Utils.open_menu.connect(open_menu)
	if not Utils.close_menu.is_connected(close_menu):
		Utils.close_menu.connect(close_menu)
	if not Utils.toggle_menu.is_connected(toggle_menu):
		Utils.toggle_menu.connect(toggle_menu)

func _ready():
	if hidden_by_default:
		close_menu()

func _exit_tree():
	if Utils.attach_menus_to_node.is_connected(_on_attach_menus_to_node):
		Utils.attach_menus_to_node.disconnect(_on_attach_menus_to_node)
	if Utils.open_menu.is_connected(open_menu):
		Utils.open_menu.disconnect(open_menu)
	if Utils.close_menu.is_connected(close_menu):
		Utils.close_menu.disconnect(close_menu)
	if Utils.toggle_menu.is_connected(toggle_menu):	
		Utils.toggle_menu.disconnect(toggle_menu)

func set_is_menu_open(open: bool):
	is_menu_open = open

func get_is_menu_open() -> bool:
	return is_menu_open

func _on_attach_menus_to_node(node : Node2D):
	print("Attaching UI element to %s" % node)
	self.get_parent().call_deferred("remove_child", self)
	node.call_deferred("add_child", self)

func open_menu(input_menu_name: StringName = menu_name): 
	if input_menu_name == menu_name:
		get_tree().set_pause(true)
		self.show()
		set_is_menu_open(true)

func close_menu(input_menu_name: StringName = menu_name):
	if input_menu_name == menu_name:
		get_tree().set_pause(false)
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
