extends Node
#class_name Utils

func _enter_tree():
	set_process(PROCESS_MODE_ALWAYS)

#region Players

var players : Array[Player] = []
var first_player : Player

func set_player_as_first(player : Player): # we dont need to remove player that is first before setting because we will have already queue free'd it from the scene tree
	first_player = player

func get_first_player():
	if first_player:
		return first_player
	else:
		push_error("%s: Player Tracker: No first player found" % self.name)
		return
		
#endregion


#region Control

signal attach_ui_to_node(node : Node2D) ## Attaches ui elements to node (usually the camera).
signal attach_menus_to_node(node : Node2D) ## Attaches menus to node (mostly the camera). Each menu will handle this differently.

signal open_menu(menu_resource : MenuResource) ## Open menu
signal close_menu(menu_resource : MenuResource) ## Close menu
signal toggle_menu(menu_resource : MenuResource) ## Open or close menu

var current_menu : Control
func set_current_menu(menu):
	current_menu = menu
func get_current_menu():
	return current_menu

signal open_message(message_resource : MessageResource)
signal connect_button_to_callable(button : BaseButton, _callable : Callable)

var current_message_resource : MessageResource:
	set(resource):
		current_message_resource = resource
	get:
		return current_message_resource

#endregion
