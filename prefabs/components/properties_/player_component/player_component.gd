extends CharacterBody2D
class_name Player

signal change_orientation
signal just_jumped

@export var animation_tree : AnimationTree
@export var stats_component : StatsComponent
@export var orientation_handler : OrientationHandler2DSimplified
@export var debug_raycasts_parent : Node
var debug_raycasts : Array[RayCast2D] = []
@export var platform_detection_area_2d : Area2D
@export var player_speed_modifier : PlayerSpeedModifier
@export var camera_2d : Camera2D

var last_input_direction : Vector2 = Vector2.RIGHT
var input_direction : Vector2 = Vector2.ZERO

var secondary_last_input_direction : Vector2 = Vector2.RIGHT
var secondary_input_direction : Vector2 = Vector2.ZERO

var cur_max_speed : Vector2 ## used at runtime to modify the max speed of the player

var jump_max : int = -1 ## used at runtime to add additonal jumps via gameplay mechanics
var available_jumps : int = -1 ## current available jumps dependent on whether the player has touched the ground or not

#var is_idling : bool = true
var is_attacking : bool = false
var is_jumping : bool = false

func _ready():
	Utils.set_player_as_first(self)
	
	Utils.attach_ui_to_node.emit(camera_2d)
	Utils.attach_menus_to_node.emit(camera_2d) # Attach menus to camera at runtime (to avoid cyclical errors when they are part of player scene)
	
	for raycast in debug_raycasts_parent.get_children(): # These raycasts show where joysticks and such are pointing
		if raycast is RayCast2D:
			debug_raycasts.append(raycast)
	
	call_deferred("_await_game_state")
	SignalBus.phantom_camera_follow_target.emit(self)
	
	stats_component.health_changed.connect(_on_health_changed)

func _await_game_state():
	reset_cur_max_speed()
	print(cur_max_speed)
	reset_jump_max()
	print(jump_max)
	reset_available_jumps()

func _physics_process(_delta):
	get_input_direction()
	debug_raycasts[0].rotation = Vector2.RIGHT.angle_to(input_direction)
	get_secondary_input_direction()
	debug_raycasts[1].rotation = Vector2.RIGHT.angle_to(secondary_input_direction)

func save() -> Dictionary:
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		
		"groups" : get_groups(),
		
		"pos_x" : snappedf(position.x, 0.01), # Vector2 is not supported by JSON
		"pos_y" :  snappedf(position.y, 0.01),
		"current_health" : stats_component.cur_health,
	}
	return save_dict


func get_input_direction():
	if (last_input_direction != input_direction 
	and input_direction != Vector2.ZERO):
		last_input_direction = input_direction
	input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

func get_secondary_input_direction():
	if (secondary_last_input_direction != secondary_input_direction 
	and secondary_input_direction != Vector2.ZERO):
		secondary_last_input_direction = secondary_input_direction
	secondary_input_direction = Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	)


func set_cur_max_speed(speed : Vector2):
	cur_max_speed = speed
	
func get_cur_max_speed():
	return cur_max_speed

func reset_cur_max_speed():
	var new_max_speed_x = stats_component.get_max_speed().x * (1 + GameState.get_speed_upgrades())
	var new_max_speed_y = stats_component.get_max_speed().y
	set_cur_max_speed(Vector2(new_max_speed_x, new_max_speed_y))

func update_cur_max_speed():
	var new_max_speed_x = stats_component.get_max_speed().x * (1 + (player_speed_modifier.stored_jumps * player_speed_modifier.modifier_upon_jumps))
	var new_max_speed_y = stats_component.get_max_speed().y
	set_cur_max_speed(Vector2(new_max_speed_x, new_max_speed_y))
	print(cur_max_speed)

func set_jump_max(jumps : int):
	jump_max = jumps

func reset_jump_max(): # set stats_component.jump_max to GameState.jump_upgrades + 1
	set_jump_max(1 + GameState.get_jump_upgrades()) # Player has one jump by default


func set_available_jumps(i : int):
	available_jumps = clampi(i, 0, jump_max)

func reset_available_jumps():
	set_available_jumps(jump_max)


func update_animation_parameters():
	if is_attacking:
		animation_tree["parameters/conditions/is_attacking"] = true
	else:
		animation_tree["parameters/conditions/is_attacking"] = false

func is_on_platform() -> bool:
	for idx in get_slide_collision_count():
		var collision = get_slide_collision(idx)
		var normal = collision.get_normal()
		if normal == Vector2(0, -1):
			print("Is on platform")
			return true
	return false

func is_inside_platform() -> bool:
	if platform_detection_area_2d.has_overlapping_bodies():
		print("Is inside platform")
		return true
	return false

func is_on_roof():
	if is_on_ceiling():
		print("Is touching roof")
		return true
	return false

func _on_health_changed(current_health):
	if current_health <= 0:
		get_tree().set_pause(true)
		if SaveManager.current_save_name:
			SaveManager.load_game(SaveManager.current_save_name)
		else:
			SaveManager.new_game("0")
