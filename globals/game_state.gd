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
		"speed_upgrades" : speed_upgrades,
		"jump_upgrades" : jump_upgrades,
		"health_upgrades" : health_upgrades,
	}
	return save_dict


#region Player Stage

var stage_progress : Dictionary = { # To indicate if the player has finished a stage or not.
	"res://scenes/stages/stage_1.tscn" : false
}

func set_stage_progress(stage : StringName, is_completed : bool):
	if stage in stage_progress:
		stage_progress[stage] = is_completed
	else:
		push_error("Stage: %s does not exist" % stage)

func get_stage_progress(stage : StringName):
	if stage_progress and stage_progress[stage]:
		return stage_progress[stage]
	else:
		push_error("Stage: %s does not exist" % stage)
		return false

var current_stage : StringName
func set_current_stage(stage : StringName):
	current_stage = stage
func get_current_stage():
	return current_stage

#endregion


#region Player Unlockables

var jump_upgrades : int = 0 # Amt of upgrades player has will increase max jumps by 1 for each
func get_jump_upgrades():
	return jump_upgrades

var health_upgrades : int = 0

var speed_upgrades : int = 0
var speed_upgrades_modifier : float = 0.02 # the value at which speed upgrades will be multiplied, so as to modify the default max_speed of the statscomponent
func get_speed_upgrades():
	return snappedf(speed_upgrades * speed_upgrades_modifier, 0.01)
	
#endregion


#region Popups

#endregion

#region Fmod
var fmod_reverb_event_guid : StringName = '{d4add041-7991-4e9a-8ef6-bc79f8a42eb6}'
@onready var fmod_cave_reverb_event : FmodEvent = FmodServer.create_event_instance_with_guid(fmod_reverb_event_guid as String)

var fmod_menu_lowpass_guid : StringName = '{71350541-382d-4bfa-b55d-60061c3f710b}'
@onready var fmod_menu_lowpass_event : FmodEvent = FmodServer.create_event_instance_with_guid(fmod_menu_lowpass_guid as String)
#endregion
