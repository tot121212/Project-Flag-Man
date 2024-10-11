extends CharacterBody2D
class_name Player

signal change_orientation

@export var animation_tree : AnimationTree
@export var stats_component : StatsComponent
@export var orientation_handler : OrientationHandler2DSimplified
@export var debug_raycasts_parent : Node
var debug_raycasts : Array[RayCast2D] = []
@export var platform_detection_area_2d : Area2D

var last_input_direction : Vector2 = Vector2.RIGHT
var input_direction : Vector2 = Vector2.ZERO

var secondary_last_input_direction : Vector2 = Vector2.RIGHT
var secondary_input_direction : Vector2 = Vector2.ZERO

var is_idle : bool = false
var is_attacking : bool = false
var is_jumping: bool = false

var available_jumps : int

func _ready():
	for raycast in debug_raycasts_parent.get_children():
		if raycast is RayCast2D:
			debug_raycasts.append(raycast)
	reset_available_jumps()

func _physics_process(_delta):
	get_input_direction()
	debug_raycasts[0].rotation = Vector2.RIGHT.angle_to(input_direction)
	get_secondary_input_direction()
	debug_raycasts[1].rotation = Vector2.RIGHT.angle_to(secondary_input_direction)

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

func update_animation_parameters():
	if is_attacking:
		animation_tree["parameters/conditions/is_attacking"] = true
	else:
		animation_tree["parameters/conditions/is_attacking"] = false

func set_available_jumps(new_available_jumps):
	available_jumps = clampi(new_available_jumps, 0, stats_component.jump_max)

func reset_available_jumps():
	set_available_jumps(stats_component.jump_max)

func is_on_platform() -> bool:
	print("Is on platform")
	for idx in get_slide_collision_count():
		var collision = get_slide_collision(idx)
		var normal = collision.get_normal()
		if normal == Vector2(0, -1):
			return true
	return false

func is_inside_platform() -> bool:
	print("Is inside platform")
	if platform_detection_area_2d.has_overlapping_bodies():
		return true
	return false
