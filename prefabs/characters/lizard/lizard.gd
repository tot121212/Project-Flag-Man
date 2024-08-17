extends CharacterBody2D
class_name EnemyLizard

signal change_orientation

@export var sprite : Sprite2D
@export var orientation_handler : Node2D
@export var detection_raycaster : Node
@export var stats_component : Node2D
@export var aggro_state_machine : StateMachine
@export var movement_attack_state_machine : StateMachine
@export var floor_detect_raycasts : Node2D
@export var velocity_component : Node2D
@export var navigation_agent : NavigationAgent2D

@onready var ray_front_down : RayCast2D = $Raycasts/FrontDown
@onready var ray_back_down : RayCast2D = $Raycasts/BackDown
@onready var ray_front : RayCast2D = $Raycasts/Front

var direction : Vector2 # direction is trying to go
var prev_direction : Vector2 # prev direction went in

func _physics_process(_delta):
	move_and_slide()
