extends State
class_name PlayerCombatAttack

@export var root : Node2D
@export var sparkles_sprite : Sprite2D
var proj_player_flag_scene = preload("res://prefabs/characters/player/Player Flag/player_flag.tscn")

@export var throw_flag_cooldown : Timer

func state_update(_delta):
	if Input.is_action_just_pressed("shoot"):
		if throw_flag_cooldown.is_stopped():
			throw_flag_cooldown.start()
			root.is_attacking = true
			root.update_animation_parameters()
			# throw_flag() is triggered with animation
			print("player attack input")
	elif root.is_attacking:
		root.is_attacking = false

var projectile_instance_node_paths : Array[NodePath] = []
func throw_flag():
	# new proj
	var new_flag : Node
	if proj_player_flag_scene.can_instantiate():
		new_flag = proj_player_flag_scene.instantiate()
	else: 
		return
	
	# adjust vars
	if root.secondary_input_direction != Vector2.ZERO:
		new_flag.projectile_component.direction = root.secondary_input_direction
	elif root.input_direction != Vector2.ZERO:
		new_flag.projectile_component.direction = root.input_direction
	else:
		new_flag.projectile_component.direction = Vector2(root.orientation_handler.last_direction.x, 0)
	new_flag.global_position = Vector2(root.global_position.x + (5 * signf(new_flag.projectile_component.direction.x)), root.global_position.y - 3)
	
	# connect signal to delete path from array when applicable
	new_flag.was_queue_freed.connect(_proj_deleted)
	
	# add to tree
	root.get_parent().add_child(new_flag)
	
	# add to array
	projectile_instance_node_paths.append(new_flag.get_path())

func _proj_deleted(node_path):
	projectile_instance_node_paths.erase(node_path)
	print("proj node path deleted from node path array")
