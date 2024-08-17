extends CharacterBody2D

signal change_orientation

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const TWO_DECIMALS: float = 0.01 # var for 2 decimal points in the snapped function

@export var jump_velocity: float = -350.0
@export var min_speed: float = 30.0
@export var max_speed: float = 200.0
@export var x_acceleration: float = 1.0

@onready var animation_tree = $AnimationTree

var direction : Vector2
var prev_direction : Vector2

var is_idle : bool = false
var is_attacking : bool = false
var is_landing: bool = false

func _physics_process(_delta):
	direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

func update_animation_parameters():
	if is_attacking:
		animation_tree["parameters/conditions/is_attacking"] = true
	else:
		animation_tree["parameters/conditions/is_attacking"] = false
