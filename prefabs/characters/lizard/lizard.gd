extends CharacterBody2D
class_name EnemyLizard

signal change_orientation

@export var sprite : Sprite2D
@export var orientation_handler : Node2D
@export var detection_raycaster : Node
@export var stats_component : Node2D
@export var aggro_state_machine : StateMachine
@export var movement_attack_state_machine : StateMachine
@export var velocity_component : Node2D
@export var navigation_agent : NavigationAgent2D
@export var object_detect_raycasts : ObjectDetectRaycasts

var direction : Vector2 = Vector2.ZERO # direction self is trying to go
var current_target : Node # node of player or the target of aggro in general
var target_group : String # the group with which self should attack

var target_position : Vector2 # what position are we tryna go to

func _physics_process(delta):
	if not velocity_component.is_jumping:
		velocity_component.apply_friction(delta)
	else: 
		velocity_component.apply_jump(delta)
	move_and_slide()
