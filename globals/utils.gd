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
signal open_message(message_resource : MessageResource)
signal input_message_continue_callable(_callable : Callable)
#endregion

#region Victory and Loss
var current_stage : StringName
func set_current_stage(stage_name : StringName):
	current_stage = stage_name

signal win_current_stage
#endregion
