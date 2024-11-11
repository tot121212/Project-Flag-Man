extends Node
#class_name SaveManager

signal stage_ready

@export var first_scene_path : String = "res://scenes/stages/stage_1.tscn"

var current_save_name : String

func _enter_tree():
	set_process(PROCESS_MODE_ALWAYS)
	ensure_save_directories_exist()

func ensure_save_directories_exist():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
	print("Created saves directory")

#func save():
	#var save_dict = {
		#"filename" : get_scene_file_path(),
		#"parent" : get_parent().get_path(),
		#"pos_x" : position.x, # Vector2 is not supported by JSON
		#"pos_y" : position.y,
		#"attack" : attack,
		#"defense" : defense,
		#"current_health" : current_health,
		#"max_health" : max_health,
		#"damage" : damage,
		#"regen" : regen,
		#"experience" : experience,
		#"tnl" : tnl,
		#"level" : level,
		#"attack_growth" : attack_growth,
		#"defense_growth" : defense_growth,
		#"health_growth" : health_growth,
		#"is_alive" : is_alive,
		#"last_attack" : last_attack
	#}
	#return save_dict

func new_game(save_name : String):
	print("SaveManager: Starting new game")
	set_current_save_name(save_name)
	open_first_scene()

func open_first_scene():
	get_tree().change_scene_to_file(first_scene_path)

# TODO: fix broken saving/loading in certain circumstances, possibly due to Utils.first_player code

var can_save : bool = true # to stop people from saving over and over again while another save is still processing
func save_game(save_name : String = current_save_name): # input save name and get save file with name
	if can_save:
		can_save = false; print("SaveManager: Saving game")
		
		var tree = get_tree()
		if not tree.is_paused():
			tree.set_pause(true)
			
		set_current_save_name(save_name); print("SaveManager: Current save file name: %s" % save_name)
		
		var save_path = get_save_path(save_name); print("SaveManager: Save file path: %s" % str(save_path))
		var save_file = FileAccess.open(save_path, FileAccess.WRITE); print("SaveManager: Save file opened: %s" % str(save_file)) # open save file for writing
		if not save_file:
			push_error("SaveManager: Error during save file open and/or creation at path: %s" % save_path)
			return
		
		var save_nodes : Array = get_tree().get_nodes_in_group("Persist"); print("SaveManager: Saved nodes: %s" % str(save_nodes)) # get persistent nodes
		save_nodes.append_array(get_tree().get_nodes_in_group("Global")) # add global nodes as well
		
		for node in save_nodes: # for each of those nodes
			print("SaveManager: Attempting to save node: %s" % node)
			
			var is_node_global = node.is_in_group("Global")
			
			if node.scene_file_path.is_empty() and not is_node_global: # if the node is not instanced, skip
				push_warning("SaveManager: persistent node '%s' is not an instanced scene, skipped" % node.name)
				continue
			
			if !node.has_method("save"): # if node does not have save method, skip
				push_warning("SaveManager: persistent node '%s' is missing a save() function, skipped" % node.name)
				continue
			
			#if node is Player and not node == Utils.first_player: # Check if node is player and is not first player, if so, skip
				#push_warning("SaveManager: persistent node '%s' is not first player, skipped" % node.name)
				#continue
			
			var node_data = node.call("save"); print("SaveManager: Called save on %s" % str(node_data)) # call save method on node
			
			var json_string = JSON.stringify(node_data); print("SaveManager: Saved json string: %s" % json_string) # stringify the node data to json format
			save_file.store_line(json_string) # store json data
		
		print("SaveManager: Game saving finished")
		save_file.close() # close file
	can_save = true

var default_load_order = 0
func load_game(save_name : String): 
	print("SaveManager: Loading game")
	
	var tree = get_tree()
	if not tree.is_paused():
		tree.set_pause(true)
	
	set_current_save_name(save_name); print("SaveManager: Current save file name: %s" % save_name)
	
	var save_path = get_save_path(save_name); print("SaveManager: Current save file path: %s" % str(save_path))
	if not FileAccess.file_exists(save_path): # if file doesnt exist, skip
		print("SaveManager: No save file to load")
		return
	
	var save_file : FileAccess = FileAccess.open(save_path, FileAccess.READ); print("SaveManager: Save file: %s" % str(save_file)) # read save file into memory
	if save_file.get_position() != 0:
		save_file.seek(0) # seek back to beginning before loading
	
	var node_data : Array[Dictionary] = []
	parse_save_file(save_file, node_data)
	save_file.close() # after parsing, close file as it is not needed in memory
	sort_node_data(node_data) # sort parsed data
	
	load_current_stage(node_data)
	free_persistents()
	load_nodes(node_data)
	
	# Here is where custom logic will be placed for special node types in-case it's needed
	
	
	print("SaveManager: Game loading finished")

func parse_save_file(save_file, node_data): # Parse data into an array of dictionaries that will be easily searchable
	while save_file.get_position() < save_file.get_length(): # while we are not at the end of the save file
		var json_string : String = save_file.get_line(); print("SaveManager: JSON String: %s" % json_string) # get line with /n or /r
		var json : JSON = JSON.new() # make new helper class
		
		var parse_result : Error = json.parse(json_string) # parse file line from json to node data
		if not parse_result == OK: # if result not ok, skip
			push_error("SaveManager: JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		node_data.append(json.data) # get data from the json object

func sort_node_data(node_data : Array[Dictionary]): # Sort data based on dictionary key/value pair, "load_order"
	node_data.sort_custom(sort_node_data_comparator)
	print("SaveManager: Node data sorted: " + str(node_data))

func sort_node_data_comparator(a, b):
	# We need to set any defaults first
	for i : Dictionary in [a, b]:
		if not i.has("load_order"):
			i["load_order"] = default_load_order # if load order doesnt exists, set to default
	
	# Then we will compare load order
	if a["load_order"] > b["load_order"]:
		return true
	return false

func load_current_stage(node_data : Array[Dictionary]): # loads player 1 current stage before anything else
	for dict in node_data:
		if dict.has("current_stage"):
			get_tree().set_current_scene(null)
			if get_tree().change_scene_to_file(dict["current_stage"]) != OK:
				print("SaveManager: Could not change to current stage scene from file")
			while get_tree().get_current_scene() != null:
				await get_tree().process_frame
		break
	return

func free_persistents(): # free persistent nodes from a scene
	get_tree().set_pause(false)
	var save_nodes = get_tree().get_nodes_in_group("Persist"); print("SaveManager: Nodes that match save file: %s" % str(save_nodes)) # get persistent nodes
	for node in save_nodes: # for each save node
		if node.is_inside_tree() and not node.is_in_group("Global"): # Free non globals
			node.queue_free(); print("SaveManager: Freeing: %s" % node) # free them
	await get_tree().process_frame

func load_nodes(node_data : Array[Dictionary]): # load persistents
	var node : Node
	var globals = get_tree().get_nodes_in_group("Global")
	
	for dict in node_data:
		var has_global_group : bool = false
		if dict.has("groups"): # Checks if global already exists, because globals cannot be instantiated.
			for group in dict["groups"]:
				if group == "Global":
					has_global_group = true
		
		if has_global_group:
			for global in globals:
				var script = global.get_script()
				if script and script.get_path() == dict["filename"]: # this only works by virtue of globals being singletons
					node = global # then we dont need to instantiate it
					break
		
		else:
			if dict.has("filename"):
				node = load(dict["filename"]).instantiate(); print("SaveManager: Save file node instantiated: %s" % node) # load object from save data
		
		if node and dict.has("parent"):
			var _parent = get_node(dict["parent"])
			if _parent:
				_parent.add_child(node) # add to scene tree as child of its parent
			else:
				print("SaveManager: No parent found for %s" % node)
		if node is Node2D and dict.has("pos_x") and dict.has("pos_y"):
			node.position = Vector2(dict["pos_x"], dict["pos_y"]) # change its pos to original pos
		
		for key in dict:
			match key:
				"load_order", "filename", "parent", "pos_x", "pos_y": # ignore load order and others
					continue
			node.set(key, dict[key]) # set all other keys on node to values from dict


func set_current_save_name(save_name : String):
	if current_save_name != save_name:
		current_save_name = save_name

func get_save_path(save_name : String) -> String: 
	return "user://saves/" + save_name + ".save"

func trigger_death():
	var tree : SceneTree = get_tree()
	var scene : Node = tree.get_current_scene()
	
	scene.set_process(false)
	scene.set_physics_process(false)
	
	if SaveManager.current_save_name:
		SaveManager.load_game(SaveManager.current_save_name)
	else:
		SaveManager.new_game("0")
