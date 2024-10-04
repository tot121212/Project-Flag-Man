extends State
class_name PlayerCombatAttack

@export var root : Node2D
@export var sparkles_sprite : Sprite2D
@export var projectile_organizer : ProjectileOrganizer
var proj_player_flag_scene = preload("res://prefabs/characters/player/Player Flag/player_flag.tscn")
var most_recent_flags : Array[Projectile] = [] # keeps track of most recent flags for use with freeze ability

@export var throw_flag_cooldown : Timer

func state_update(_delta):
	if Input.is_action_just_pressed("shoot"):
		if throw_flag_cooldown.is_stopped():
			throw_flag_cooldown.start()
			root.is_attacking = true
			root.update_animation_parameters()
			# throw_flag() is triggered with animation
			#print("player attack input")
	if Input.is_action_just_pressed("use"):
		freeze_flags()
	elif root.is_attacking:
		root.is_attacking = false

func throw_flag():
	# new proj
	var new_flag : Node
	if proj_player_flag_scene.can_instantiate():
		# make new flag
		new_flag = proj_player_flag_scene.instantiate()
		if is_instance_valid(new_flag):
			#print("valid instance of flag")
			projectile_organizer.add_child(new_flag)
			# adjust vars
			if root.secondary_input_direction != Vector2.ZERO:
				root.change_orientation.emit(root.secondary_input_direction)
				new_flag.projectile_component.direction = root.secondary_input_direction
			elif root.input_direction != Vector2.ZERO:
				new_flag.projectile_component.direction = root.input_direction
			else:
				new_flag.projectile_component.direction = Vector2(root.orientation_handler.last_direction.x, 0)
			new_flag.global_position = Vector2(root.global_position.x + (5 * signf(new_flag.projectile_component.direction.x)), root.global_position.y - 3)
			#print("New Flag Pos: " + str(new_flag.global_position))
			#print("Root Pos: " + str(root.global_position))
			
			# set most recent flags
			most_recent_flags.clear()
			most_recent_flags.append(new_flag)
		else:
			push_warning("new flag was not instantiated properly")
	else:
		push_warning("cant spawn projectile")

var flags_currently_frozen : Array[Projectile] = []
var flags_just_unfrozen : Array[Projectile] = []
func freeze_flags():
	for flag in flags_currently_frozen:
		if is_instance_valid(flag):
			flag.call("unfreeze")
			flags_currently_frozen.erase(flag)
			flags_just_unfrozen.append(flag)
			print("unfreezing " + str(flag))
	
	for flag in most_recent_flags:
		if is_instance_valid(flag) and not flag in flags_just_unfrozen:
			flag.call("freeze")
			flags_currently_frozen.append(flag)
			print("freezing " + str(flag))
	
	if flags_just_unfrozen:
		flags_just_unfrozen.clear()
