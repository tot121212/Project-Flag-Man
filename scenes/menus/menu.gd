extends Control
class_name Menu
# Make sure to super all necessary functions

@export var menu_resource : MenuResource
@export var hidden_by_default : bool = false ## Is this node hidden by default
@export var default_focus: Control ## The control with which focus will be automatically set to upon the menus opening

var is_menu_open: bool = false
@export var is_menu_attachable : bool = true ## Used to make menu not be connected to attach signal

@export_category("Fmod")
@export var should_start_fmod_menu_lowpass : bool = false ## if the menu should start the fmod menu lowpass when you open and close it
@export var should_stop_fmod_menu_lowpass : bool = false ## if the menu should stop the fmod menu lowpass when you open and close it

func _enter_tree():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	if is_menu_attachable:
		connect_menu_signals()

func _ready():
	init_hidden_by_default()

func _input(event: InputEvent) -> void:
	if event.is_action_released("accept") and get_is_menu_open():
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			print("Focused control pressed: %s" % focus_owner)
			focus_owner.pressed.emit()
			focus_owner.button_up.emit()

func _exit_tree():
	disconnect_menu_signals()


func init_hidden_by_default():
	if hidden_by_default:
		close_menu()
	else:
		open_menu()

func connect_menu_signals():
	if menu_resource:
		if not Utils.open_menu.is_connected(open_menu):
			Utils.open_menu.connect(open_menu)
		if not Utils.close_menu.is_connected(close_menu):
			Utils.close_menu.connect(close_menu)
		if not Utils.toggle_menu.is_connected(toggle_menu):
			Utils.toggle_menu.connect(toggle_menu)
	else:
		push_error("No menu resource defined")

func disconnect_menu_signals():
	if Utils.open_menu.is_connected(open_menu):
		Utils.open_menu.disconnect(open_menu)
	if Utils.close_menu.is_connected(close_menu):
		Utils.close_menu.disconnect(close_menu)
	if Utils.toggle_menu.is_connected(toggle_menu):	
		Utils.toggle_menu.disconnect(toggle_menu)

func set_is_menu_open(open: bool):
	is_menu_open = open

func get_is_menu_open(i: Callable = self.is_visible): 
	if i is Callable:
		var result = i.call()
		if result is bool: # Callable should return a boolean
			set_is_menu_open(result)
			return result
	else:
		print("Did not input valid callable for %s" % self.name)

func _on_attach_menus_to_node(node : Node2D):
	self.get_parent().call_deferred("remove_child", self)
	node.call_deferred("add_child", self); print("Attaching Menu %s to %s" % [menu_resource.menu_name, node])

func open_menu(input_menu_resource : MenuResource = menu_resource):
	if input_menu_resource == menu_resource:
		print("Opening menu: %s" % input_menu_resource.menu_name)
		get_tree().set_pause(true) # pause game
		self.show() # show menu
		set_is_menu_open(true) # menu is open
		Utils.set_current_menu(self) # current menu is self
		if default_focus:
			default_focus.grab_focus() # grab focus
		else:
			print("No default Focus Control Node set for Menu")
		
		if should_start_fmod_menu_lowpass:
			GameState.fmod_menu_lowpass_event.start()
		
		return true
	return false

func close_menu(input_menu_resource: MenuResource = menu_resource):
	if input_menu_resource == menu_resource:
		print("Closing menu: %s" % input_menu_resource.menu_name)
		get_tree().set_pause(false)
		self.hide()
		set_is_menu_open(false)
		
		if should_stop_fmod_menu_lowpass:
			GameState.fmod_menu_lowpass_event.stop(0)

func toggle_menu(input_menu_resource: MenuResource = menu_resource):
	if input_menu_resource == menu_resource:
		print("Toggling menu: %s" % input_menu_resource.menu_name)
		if not get_is_menu_open():
			open_menu(input_menu_resource)
		else:
			close_menu(input_menu_resource)
