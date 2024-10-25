extends Node
#class_name Utils

func _enter_tree():
	set_process(PROCESS_MODE_ALWAYS)

#region Player
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

#region Controllers

#endregion
