extends Node
#class_name GameState

func _enter_tree():
	set_process(PROCESS_MODE_ALWAYS)
	add_to_group("Global")

func save():
	var save_dict = {
		"filename" : get_script().get_path(),
		
		"load_order" : -1,
		"groups" : get_groups(),
		
		"current_stage" : get_current_stage(),
		"stage_progress" : stage_progress,
		"jump_upgrades" : jump_upgrades,
		"health_upgrades" : health_upgrades,
	}
	return save_dict

#region Player Stage
var stage_progress : Dictionary = { # To indicate if the player has finished a stage or not.
	"Stage1" : false
}

func get_current_stage():
	var path = get_tree().get_current_scene().get_scene_file_path()
	print("Current stage path: %s" % path)
	return path
#endregion

#region Player Unlockables
var jump_upgrades : int = 0 # Amt of upgrades player has will increase max jumps by 1 for each
var health_upgrades : int = 0
#endregion
