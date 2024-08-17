extends State

@export var root: Node2D

@export var target_group : String = "Player"

func state_enter():
	# initialize first target
	var closest_target : Node2D = get_tree().get_first_node_in_group(target_group)
	var distance_to_closest_target : float = root.global_position.distance_to(closest_target.global_position)
	
	# check all targets in target_group
	for target in get_tree().get_nodes_in_group(target_group):
		if distance_to_closest_target > root.global_position.distance_to(target.global_position):
			closest_target = target
			distance_to_closest_target = root.global_position.distance_to(target.global_position)

#func state_physics_update(_delta: float):
	#var direction = target.global_position - root.global_position
	
	#if direction.length() > 25:
		#root.velocity = direction
	#else:
		#root.velocity = Vector2()
